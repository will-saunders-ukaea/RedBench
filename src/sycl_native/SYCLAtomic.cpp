
#include <chrono>
#include <cstdint>
#include <iostream>
#include <CL/sycl.hpp>

#if defined (__INTEL_LLVM_COMPILER)
    #define ATOMIC_REF sycl::ext::oneapi::atomic_ref
#else
    #define ATOMIC_REF sycl::atomic_ref
#endif

class add_runner;

extern "C" int c_runner(
    const int64_t gpu_device,
    const int64_t num_elements,
    const int64_t num_sources,
    const int64_t num_components,
    const int64_t * source_indices,
    const double * source_values,
    double * elements,
    double * t_internal
){
    
    using namespace cl;
    
    sycl::device d;
    if (gpu_device > 0){
        try {
            d = sycl::device(sycl::gpu_selector());
        } catch (sycl::exception const &e) {
            std::cout << "Cannot select a GPU\n" << e.what() << "\n";
            std::cout << "Using a CPU device\n";
            d = sycl::device(sycl::cpu_selector());
        }
    } else {
        d = sycl::device(sycl::cpu_selector());
    }
    
    // std::cout << "Using " << d.get_info<sycl::info::device::name>() << std::endl;
    
    sycl::queue Queue(d);

    auto d_source_indices = sycl::malloc_device<int64_t>(num_sources, Queue);
    auto d_source_values = sycl::malloc_device<double>(num_sources * num_components, Queue);
    auto d_elements = sycl::malloc_device<double>(num_elements * num_components, Queue);

    auto e0 = Queue.memcpy(d_source_indices, source_indices, num_sources * sizeof(int64_t));
    auto e1 = Queue.memcpy(d_source_values, source_values, num_sources * num_components * sizeof(double));
    auto e2 = Queue.memcpy(d_elements, elements, num_elements * num_components * sizeof(double));
    e0.wait() ; e1.wait() ; e2.wait();

    std::chrono::high_resolution_clock::time_point _loop_timer_t0 = std::chrono::high_resolution_clock::now();
    
    Queue.submit(
        [&](sycl::handler& cgh) {

            cgh.parallel_for<add_runner>(sycl::range<1>(num_sources), [=](sycl::id<1> idx) {
                const int64_t index = d_source_indices[idx] - 1;
                for (int64_t cx=0 ; cx<num_components ; cx++){
                    const int64_t output_index = cx * num_elements + index;
                    const double value = d_source_values[cx * num_sources + idx];
                    

#if defined (__INTEL_LLVM_COMPILER)
                    auto element_atomic = sycl::ext::oneapi::atomic_ref<double,
                                    sycl::ext::oneapi::memory_order_acq_rel,
                                    sycl::ext::oneapi::memory_scope_device,
                                    sycl::access::address_space::global_space>(d_elements[output_index]);
                    
                    element_atomic.fetch_add(value);
#else
                    sycl::atomic_ref<
                        double,
                        sycl::memory_order::relaxed,
                        sycl::memory_scope::device
                    > element_atomic(d_elements[output_index]);
                    element_atomic.fetch_add(value);
#endif

                }
            });

        }
    );

    Queue.wait();

    std::chrono::high_resolution_clock::time_point _loop_timer_t1 = std::chrono::high_resolution_clock::now();
 std::chrono::duration<double> _loop_timer_res = _loop_timer_t1 - _loop_timer_t0;
    *t_internal= (double) _loop_timer_res.count();

    Queue.memcpy(elements, d_elements, num_elements * num_components * sizeof(double)).wait();
    
    sycl::free(d_source_indices, Queue);
    sycl::free(d_source_values, Queue);
    sycl::free(d_elements, Queue);

    return 0;
}




