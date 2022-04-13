
#include <chrono>
#include <cstdint>
#include <iostream>
#include <cuda.h>

#if !defined(__CUDA_ARCH__) || __CUDA_ARCH__ >= 600
#else
    __device__ static double atomicAdd(double *addr, double val){
        double old=*addr, assumed;
        do {
            assumed = old;
            old = __longlong_as_double(
            atomicCAS((unsigned long long int*)addr,
              __double_as_longlong(assumed),
              __double_as_longlong(val+assumed) )
            );
        } while (assumed!=old);
        return old;
    }
#endif


static inline void CHECK_CUDA(cudaError_t code){
    if (code != cudaSuccess){
        std::cout << "A CUDA error check failed." << std::endl;
    }
}


__global__ void reduce_kernel(
    const int64_t num_elements,
    const int64_t num_sources,
    const int64_t num_components,
    const int64_t * RESTRICT d_source_indices,
    const double * RESTRICT d_source_values,
    double * RESTRICT d_elements
){
    const int idx = threadIdx.x + blockIdx.x * blockDim.x; 
    if(idx < num_sources){
        
        const int64_t index = d_source_indices[idx] - 1;
        for (int64_t cx=0 ; cx<num_components ; cx++){
            const int64_t output_index = cx * num_elements + index;
            const double value = d_source_values[cx * num_sources + idx];
            atomicAdd(&d_elements[output_index], value);
        }

    }
    return;
}


extern "C" int c_runner(
    const int64_t num_threads,
    const int64_t num_elements,
    const int64_t num_sources,
    const int64_t num_components,
    const int64_t * RESTRICT source_indices,
    const double * RESTRICT source_values,
    double * RESTRICT elements,
    double * RESTRICT t_internal
){
    

    int64_t *d_source_indices;
    double *d_source_values;
    double *d_elements;

    CHECK_CUDA(cudaMalloc(&d_source_indices, num_sources * sizeof(int64_t)));
    CHECK_CUDA(cudaMalloc(&d_source_values, num_sources * num_components * sizeof(double)));
    CHECK_CUDA(cudaMalloc(&d_elements, num_elements * num_components * sizeof(double)));

    CHECK_CUDA(cudaMemcpy(
        d_source_indices, source_indices, num_sources * sizeof(int64_t), cudaMemcpyHostToDevice
    ));
    CHECK_CUDA(cudaMemcpy(
        d_source_values, source_values, num_sources * num_components * sizeof(double), cudaMemcpyHostToDevice
    ));
    CHECK_CUDA(cudaMemcpy(
        d_elements, elements, num_elements * num_components * sizeof(double), cudaMemcpyHostToDevice
    ));

    std::chrono::high_resolution_clock::time_point _loop_timer_t0 = std::chrono::high_resolution_clock::now();

    
    const int grid_size = 1 + (num_sources / num_threads);
    reduce_kernel<<<grid_size, num_threads>>>(
        num_elements,
        num_sources,
        num_components,
        d_source_indices,
        d_source_values,
        d_elements
    );

    CHECK_CUDA(cudaDeviceSynchronize());

    std::chrono::high_resolution_clock::time_point _loop_timer_t1 = std::chrono::high_resolution_clock::now();
 std::chrono::duration<double> _loop_timer_res = _loop_timer_t1 - _loop_timer_t0;
    *t_internal= (double) _loop_timer_res.count();


    CHECK_CUDA(cudaMemcpy(
        elements, d_elements, num_elements * num_components * sizeof(double), cudaMemcpyDeviceToHost
    ));

    CHECK_CUDA(cudaFree(d_source_indices));
    CHECK_CUDA(cudaFree(d_source_values));
    CHECK_CUDA(cudaFree(d_elements));

    return 0;
}



