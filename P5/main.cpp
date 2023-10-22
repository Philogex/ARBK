#include <iostream>
#include <thread>
#include <mutex>
#include <condition_variable>

void unsynchronized_a() {
	std::cout << "\n\n----UNSYNCHRONIZED----\n\n";

    std::thread t1([]() {
        for(char c = 'a'; c <= 'z'; c++) {
            std::cout << c << ' ';
        }
    });
    
    std::thread t2([]() {
    	for(int i = 0; i <= 32; i++) {
    		std::cout << i << ' ';
    	}
    });
    
    std::thread t3([]() {
    	for(char c = 'A'; c <= 'Z'; c++) {
            std::cout << c << ' ';
        }
    });

    t1.join();
    t2.join();
    t3.join();
}

void mutex_b() {
	std::cout << "\n\n----MUTEX----\n\n";

	std::mutex mtx;

    std::thread t1([&mtx]() {
        for(char c = 'a'; c <= 'z'; c++) {
        	std::lock_guard<std::mutex> lock(mtx);
            std::cout << c << ' ';
        }
    });

    std::thread t2([&mtx]() {
    	for(int i = 0; i <= 32; i++) {
    		std::lock_guard<std::mutex> lock(mtx);
    		std::cout << i << ' ';
    	}
    });

    std::thread t3([&mtx]() {
    	for(char c = 'A'; c <= 'Z'; c++) {
    		std::lock_guard<std::mutex> lock(mtx);
            std::cout << c << ' ';
        }
    });

    t1.join();
    t2.join();
    t3.join();
}

void semaphore_c() {
	std::cout << "\n\n----SEMAPHORE----\n\n";

	//local class for semaphore use
	class Semaphore {
	public:
		//m renamed to count, bc m_m doesn't look so good
		Semaphore(int count) : m_count(count){}

		//acquire
		void wait() {
			std::unique_lock<std::mutex> lock(m_mtx);
			while(m_count <= 0) {
				m_cv.wait(lock);
			}
			m_count--;
		}

		//release
		void signal() {
			std::lock_guard<std::mutex> lock(m_mtx);
			m_count++;
			m_cv.notify_one();
			//or notify_all()
		}
		
	private:
		int m_count;
		std::mutex m_mtx;
		std::condition_variable m_cv;
	};

	Semaphore sem_cout(1);

	
	std::thread t1([&sem_cout]() {
        for(char c = 'a'; c <= 'z'; c++) {
        	sem_cout.wait();
            std::cout << c << ' ';
            sem_cout.signal();
        }
    });
    
    std::thread t2([&sem_cout]() {
    	for(int i = 0; i <= 32; i++) {
    		sem_cout.wait();
    		std::cout << i << ' ';
    		sem_cout.signal();
    	}
    });
    
    std::thread t3([&sem_cout]() {
    	for(char c = 'A'; c <= 'Z'; c++) {
    		sem_cout.wait();
            std::cout << c << ' ';
            sem_cout.signal();
        }
    });

    t1.join();
    t2.join();
    t3.join();
}

int main() {
	unsynchronized_a();

	mutex_b();

	semaphore_c();
    
    return 0;
}