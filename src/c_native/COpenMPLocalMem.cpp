
#include <chrono>
#include <cstdint>
#include <iostream>
#include <omp.h>
#include <cstdlib>

#define MIN(x, y) (((x) < (y)) ? (x) : (y))

int get_thread_decomp(const int64_t N, int64_t * rstart, int64_t * rend){

    const ldiv_t pq = std::div((long) N, (long) omp_get_num_threads());
    const int64_t i = omp_get_thread_num();
    const int64_t p = pq.quot;
    const int64_t q = pq.rem;
    const int64_t n = (i < q) ? (p + 1) : p;
    const int64_t start = (MIN(i, q) * (p + 1)) + ((i > q) ? (i - q) * p : 0);
    const int64_t end = start + n;

    *rstart = start;
    *rend = end;

    return 0;
}


extern "C" int c_runner(
    const int64_t num_elements,
    const int64_t num_sources,
    const int64_t num_components,
    const int64_t * RESTRICT source_indices,
    const double * RESTRICT source_values,
    double * RESTRICT elements,
    double * RESTRICT t_internal
){

    

    const int nthreads = omp_get_max_threads();

    double * RESTRICT * RESTRICT reduction_space = (double**) malloc(nthreads * sizeof(double *));
    for (int dx=0 ; dx<nthreads ; dx++){
        reduction_space[dx] = (double *) malloc(
            num_elements * num_components * sizeof(double)
        );
    }

#pragma omp parallel for
    for (int dx=0 ; dx<nthreads ; dx++){
        for(int cx=0 ; cx<num_elements * num_components ; cx++){
            reduction_space[dx][cx] = 0.0;
        }
    }


    std::chrono::high_resolution_clock::time_point _loop_timer_t0 = std::chrono::high_resolution_clock::now();


#pragma omp parallel
    {
        const int threadid = omp_get_thread_num();
        double * RESTRICT tmp_elements = reduction_space[threadid];
        int64_t rstart, rend;

        get_thread_decomp(num_sources, &rstart, &rend);

        for(int64_t value_index=rstart ; value_index<rend ; value_index++){
            int64_t index = source_indices[value_index] - 1;

            for(int64_t cx=0 ; cx<num_components ; cx++){

                const int64_t output_index = cx * num_elements + index;
                const double value = source_values[cx * num_sources + value_index];
                tmp_elements[output_index] += value;
                
            }
        }

        get_thread_decomp(num_elements * num_components, &rstart, &rend);

#pragma omp barrier
        for(int cx=rstart ; cx<rend; cx++){
            double value = 0.0;
            for (int dx=0 ; dx<nthreads ; dx++){
                value += reduction_space[dx][cx];
            }
            elements[cx] = value;
        }

    }

    std::chrono::high_resolution_clock::time_point _loop_timer_t1 = std::chrono::high_resolution_clock::now();
 std::chrono::duration<double> _loop_timer_res = _loop_timer_t1 - _loop_timer_t0;
    *t_internal= (double) _loop_timer_res.count();

    for (int dx=0 ; dx<nthreads ; dx++){
        free(reduction_space[dx]);
    }
    free(reduction_space);

    return 0;
}




