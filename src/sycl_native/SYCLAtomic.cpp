
#include <chrono>
#include <cstdint>
#include <iostream>
#include <CL/sycl.hpp>


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

    sycl::buffer<int64_t, 1> d_source_indices(source_indices, sycl::range<1>(num_sources * num_components));
    sycl::buffer<double, 1> d_source_values(source_values, sycl::range<1>(num_sources * num_components));
    sycl::buffer<double, 1> d_elements(elements, sycl::range<1>(num_elements * num_components));

    std::chrono::high_resolution_clock::time_point _loop_timer_t0 = std::chrono::high_resolution_clock::now();
    
    Queue.submit(
        [&](sycl::handler& cgh) {
            auto a_source_indices = d_source_indices.get_access<sycl::access::mode::read>(cgh);
            auto a_source_values = d_source_values.get_access<sycl::access::mode::read>(cgh);
            auto a_elements = d_elements.get_access<sycl::access::mode::read_write>(cgh);

            cgh.parallel_for<add_runner>(sycl::range<1>(num_sources), [=](sycl::id<1> idx) {
                const int64_t index = a_source_indices[idx] - 1;
                for (int64_t cx=0 ; cx<num_components ; cx++){
                    const int64_t output_index = cx * num_elements + index;
                    const double value = a_source_values[cx * num_sources + idx];
                    
                    sycl::atomic_ref<
                        double,
                        sycl::memory_order::relaxed,
                        sycl::memory_scope::device
                    > element_atomic(a_elements[output_index]);

                    element_atomic.fetch_add(value);

                }
            });
        }

    );

    Queue.wait();


    std::chrono::high_resolution_clock::time_point _loop_timer_t1 = std::chrono::high_resolution_clock::now();
 std::chrono::duration<double> _loop_timer_res = _loop_timer_t1 - _loop_timer_t0;
    *t_internal= (double) _loop_timer_res.count();

    return 0;
}




