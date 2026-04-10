#include "xil_printf.h"
#include "mamba_test.h"

int main(void)
{
    int status;

    xil_printf("Boot mamba_test...\r\n");

    status = run_mamba_test();
    if (status != 0) {
        xil_printf("mamba_test FAILED\r\n");
    } else {
        xil_printf("mamba_test PASSED\r\n");
    }

    while (1) {
        ;
    }

    return 0;
}