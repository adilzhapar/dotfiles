#include <unistd.h>
#include <stdlib.h>
#include "network.h"
#include <stdio.h>

int main (int argc, char** argv) {
  if (argc < 2) {
    printf("Usage: %s \"<interface>\"\n", argv[0]);
    exit(1);
  }

  struct network network;
  network_init(&network, argv[1]);
  
  printf("Interface: %s\n", argv[1]);
  printf("Network row: %d\n", network.row);
  printf("Interface name from data: %s\n", network.data.ifmd_name);
  
  // Wait a bit to get baseline
  sleep(1);
  
  uint64_t prev_ibytes = 0, prev_obytes = 0;
  
  for (int i = 0; i < 5; i++) {
    uint64_t curr_ibytes = network.data.ifmd_data.ifi_ibytes;
    uint64_t curr_obytes = network.data.ifmd_data.ifi_obytes;
    
    network_update(&network);
    
    printf("Iteration %d:\n", i + 1);
    printf("  Upload: %d %s\n", network.up, "Mbps");
    printf("  Download: %d %s\n", network.down, "Mbps");
    printf("  Raw bytes in: %llu (delta: %llu)\n", network.data.ifmd_data.ifi_ibytes, 
           i > 0 ? network.data.ifmd_data.ifi_ibytes - curr_ibytes : 0);
    printf("  Raw bytes out: %llu (delta: %llu)\n", network.data.ifmd_data.ifi_obytes,
           i > 0 ? network.data.ifmd_data.ifi_obytes - curr_obytes : 0);
    printf("  Time delta: %ld.%06d seconds\n", network.tv_delta.tv_sec, network.tv_delta.tv_usec);
    
    if (i > 0) {
      double time_scale = (network.tv_delta.tv_sec + 1e-6*network.tv_delta.tv_usec);
      uint64_t delta_ibytes_raw = network.data.ifmd_data.ifi_ibytes - curr_ibytes;
      uint64_t delta_obytes_raw = network.data.ifmd_data.ifi_obytes - curr_obytes;
      double delta_ibytes_per_sec = (double)delta_ibytes_raw / time_scale;
      double delta_obytes_per_sec = (double)delta_obytes_raw / time_scale;
      double down_mbps = delta_ibytes_per_sec / 1000000.0;
      double up_mbps = delta_obytes_per_sec / 1000000.0;
      
      printf("  Calculated download Mbps: %.6f\n", down_mbps);
      printf("  Calculated upload Mbps: %.6f\n", up_mbps);
      printf("  Integer conversion download: %d\n", (int)down_mbps);
      printf("  Integer conversion upload: %d\n", (int)up_mbps);
    }
    printf("\n");
    
    sleep(1);
  }
  
  return 0;
}