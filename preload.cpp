#include <stdio.h>
#include <dlfcn.h>
#include <stdarg.h>
#include <mercury.h>
#include <mercury_macros.h>
#include <mercury_bulk.h>
#include <mercury_proc_string.h>
#include <stdlib.h>  // For getenv and atoi
#include <pthread.h> 
#include <unistd.h>
// Define an example RPC ID (this should match the server's RPC ID)
hg_id_t rpc_id;

// Generate the serialization/deserialization functions
MERCURY_GEN_PROC(rpc_input_t, ((int32_t)(input_value)))
MERCURY_GEN_PROC(rpc_output_t, ((int32_t)(output_value)))

// Function to be called by the constructor to initialize Mercury and send an RPC
void mercury_send_rpc() {
    hg_class_t *hg_class;
    hg_context_t *hg_context;
    hg_addr_t svr_addr;
    hg_handle_t handle;
    hg_return_t ret;



    const char *info_string = "ofi+tcp://";
 //   char *rank_str = getenv("PMI_RANK");
 //   int server_rank = atoi(rank_str);
    pthread_t hvac_progress_tid;
	 getpid();
    HG_Set_log_level("DEBUG");

    /* Initialize Mercury with the desired network abstraction class */
    hg_class = HG_Init(info_string, HG_TRUE);
    if (hg_class == NULL){
        printf("Could not initialize Mercury.\n");
    }

    /* Create HG context */
    hg_context = HG_Context_create(hg_class);
    if (hg_context == NULL){
        printf("Could not create Mercury context.\n");
    }

/*
    // Look up the server address
    ret = HG_Addr_lookup2(hg_class, HG_SERVER_ADDRESS, &svr_addr);
    if (ret != HG_SUCCESS) {
        fprintf(stderr, "Could not lookup address.\n");
        HG_Context_destroy(hg_context);
        HG_Finalize(hg_class);
        return;
    }

    // Register the RPC
    rpc_id = MERCURY_REGISTER(hg_class, "example_rpc", rpc_input_t, rpc_output_t, NULL);

    // Create an RPC handle
    ret = HG_Create(hg_context, svr_addr, rpc_id, &handle);
    if (ret != HG_SUCCESS) {
        fprintf(stderr, "Could not create handle.\n");
        HG_Addr_free(hg_class, svr_addr);
        HG_Context_destroy(hg_context);
        HG_Finalize(hg_class);
        return;
    }

    // Prepare input data
    rpc_input_t input;
    input.input_value = 42;

    // Forward the call
    ret = HG_Forward(handle, NULL, NULL, &input);
    if (ret != HG_SUCCESS) {
        fprintf(stderr, "Could not forward call.\n");
        HG_Destroy(handle);
        HG_Addr_free(hg_class, svr_addr);
        HG_Context_destroy(hg_context);
        HG_Finalize(hg_class);
        return;
    }

    // Wait for the response
    unsigned int actual_count;
    do {
        ret = HG_Trigger(hg_context, 0, 1, &actual_count);
    } while ((ret == HG_SUCCESS) && actual_count);

    do {
        ret = HG_Progress(hg_context, 100);
    } while (ret == HG_SUCCESS);

    // Free resources
    HG_Destroy(handle);
    HG_Addr_free(hg_class, svr_addr);
    HG_Context_destroy(hg_context);
*/
    HG_Finalize(hg_class);

}

// Constructor function to print a message when the library is loaded and send an RPC
__attribute__((constructor)) void preload_constructor() {
    printf("Empty LD_PRELOAD shared library loaded.\n");
    mercury_send_rpc();
}

// Override a sample function (e.g., printf) to do nothing
int printf(const char *format, ...) {
    // Get the original printf function
    static int (*real_printf)(const char *, ...) = NULL;
    if (!real_printf) {
        real_printf = (int (*)(const char *, ...))dlsym(RTLD_NEXT, "printf");
    }

    va_list args;
    va_start(args, format);
    int result = real_printf(format, args);
    va_end(args);

    return result;
}

