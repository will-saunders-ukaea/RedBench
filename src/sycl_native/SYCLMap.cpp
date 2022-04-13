
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

    

    int64_t* layers = (int64_t*) malloc(num_sources * sizeof(int64_t));
    int64_t* counters = (int64_t*) malloc((num_elements+1) * sizeof(int64_t));
    int64_t* source_map = (int64_t*) malloc(num_sources * sizeof(int64_t));

    if ((counters == NULL) || (layers == NULL) || (source_map == NULL) ){
        std::cout << "Error: malloc failed\n";
        return 0;
    }
    for(int cx=0 ; cx<num_elements+1 ; cx++){
        counters[cx] = 0;
    }

    for(int64_t sourcex=0 ; sourcex<num_sources ; sourcex++){
        const int64_t cell = source_indices[sourcex] - 1;
        const int64_t layer = counters[cell];
        counters[cell]++;
        layers[sourcex] = layer;
    }

    //inclusive scan
    int64_t last_count = counters[0];
    counters[0] = 0;
    for(int cx=1 ; cx<num_elements+1 ; cx++){
        int64_t curr_count = counters[cx];
        counters[cx] = last_count;
        last_count += curr_count;
    }

    if (last_count != num_sources){
        std::cout << "Error: Map building failed\n";
        std::cout << "Num_sources " << num_sources << " last_count " << last_count << "\n";
        return 0;
    }
    
    // build element to source map
    for(int64_t sourcex=0 ; sourcex<num_sources ; sourcex++){
        const int64_t cell = source_indices[sourcex] - 1;
        const int64_t layer = layers[sourcex];
        const int64_t elements_start = counters[cell];
        source_map[elements_start + layer] = sourcex;
    }
    
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
    auto d_counters = sycl::malloc_device<int64_t>(num_elements+1, Queue);
    auto d_source_map = sycl::malloc_device<int64_t>(num_sources, Queue);


    auto e0 = Queue.memcpy(d_source_indices, source_indices, num_sources * sizeof(int64_t));
    auto e1 = Queue.memcpy(d_source_values, source_values, num_sources * num_components * sizeof(double));
    auto e2 = Queue.memcpy(d_elements, elements, num_elements * num_components * sizeof(double));
    auto e3 = Queue.memcpy(d_counters, counters, (num_elements + 1) * sizeof(int64_t));
    auto e4 = Queue.memcpy(d_source_map, source_map, num_sources * sizeof(int64_t));
    e0.wait() ; e1.wait() ; e2.wait(); e3.wait(); e4.wait();

    std::chrono::high_resolution_clock::time_point _loop_timer_t0 = std::chrono::high_resolution_clock::now();
    
    Queue.submit(
        [&](sycl::handler& cgh) {

            cgh.parallel_for<add_runner>(sycl::range<1>(num_elements * num_components), [=](sycl::id<1> idx_cx) {
                
                const int64_t idx = idx_cx / num_components;
                const int64_t cx = idx_cx % num_components;

                const int64_t map_start = d_counters[idx];
                const int64_t map_end = d_counters[idx + 1];
                //for (int64_t cx=0 ; cx<num_components ; cx++){
                    
                    double value = 0.0;
                    for(int64_t map_idx=map_start ; map_idx<map_end ; map_idx++){
                        const int64_t source_index = d_source_map[map_idx];
                            value += d_source_values[cx * num_sources + source_index];
                    }
                    const int64_t output_index = cx * num_elements + idx;
                    d_elements[output_index] = value;
                //}

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
    sycl::free(d_counters, Queue);
    sycl::free(d_source_map, Queue);


    free(counters);
    free(layers);
    free(source_map);

    return 0;
}




