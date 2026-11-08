#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/process.h>
#include <net/net.h>
#include <net/netctl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <io/pad.h>

#define PROXY_IP   "192.168.0.10"
#define PROXY_PORT 3000

SYS_PROCESS_PARAM(1001, 0x100000);

static int http_get(const char *path, char *out, int outsz) {
    int s = socket(AF_INET, SOCK_STREAM, 0);
    if (s < 0) return -1;

    struct sockaddr_in a;
    memset(&a, 0, sizeof(a));
    a.sin_family = AF_INET;
    a.sin_port = htons(PROXY_PORT);
    inet_pton(AF_INET, PROXY_IP, &a.sin_addr);

    if (connect(s, (struct sockaddr *)&a, sizeof(a)) < 0) {
        close(s);
        return -2;
    }

    char req[512];
    snprintf(req, sizeof(req),
             "GET %s HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n",
             path, PROXY_IP);
    send(s, req, strlen(req), 0);

    int total = 0, n;
    while (total < outsz - 1 &&
           (n = recv(s, out + total, outsz - 1 - total, 0)) > 0)
        total += n;
    out[total] = 0;
    close(s);
    return total;
}

int main(void) {
    netInitialize();
    ioPadInit(7);

    static char buf[16384];
    int r = http_get("/api/search?q=teste", buf, sizeof(buf));
    printf("Resposta do proxy: %d bytes\n%s\n", r, r > 0 ? buf : "erro");

    padInfo pi;
    padData pd;
    while (1) {
        ioPadGetInfo(&pi);
        if (pi.status[0]) {
            ioPadGetData(0, &pd);
            if (pd.BTN_CIRCLE) break;
        }
        usleep(50000);
    }

    netDeinitialize();
    return 0;
}