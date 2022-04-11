
#include <chrono>
#include <cstdint>
#include <iostream>

extern "C" int c_runner(
    const int64_t num_elements,
    const int64_t num_sources,
    const int64_t num_components,
    const int64_t * RESTRICT source_indices,
    const double * RESTRICT source_values,
    double * RESTRICT elements,
    double * RESTRICT t_internal
){
    std::chrono::high_resolution_clock::time_point _loop_timer_t0 = std::chrono::high_resolution_clock::now();
    

#pragma omp parallel for
    for(int64_t value_index=0 ; value_index<num_sources ; value_index++){
        int64_t index = source_indices[value_index] - 1;

        for(int64_t cx=0 ; cx<num_components ; cx++){

            const int64_t output_index = cx * num_elements + index;
            const double value = source_values[cx * num_sources + value_index];
#pragma omp atomic
            elements[output_index] += value;
            
        }

    }

    std::chrono::high_resolution_clock::time_point _loop_timer_t1 = std::chrono::high_resolution_clock::now();
 std::chrono::duration<double> _loop_timer_res = _loop_timer_t1 - _loop_timer_t0;
    *t_internal= (double) _loop_timer_res.count();

    return 0;
}




