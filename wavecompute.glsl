#[compute]
#version 430
#define X 40
#define Y 40
#define ITERS 1
#define ERROR 50000u
#define N_STATES 4


shared uint state;


layout (local_size_x = X, local_size_y = Y, local_size_z = ITERS) in;
layout (set = 0, binding = 0, std430) restrict buffer MyDataBuffer {
    uint data[];
}
my_data_buffer;

layout (set = 0, binding = 1, std430) restrict buffer ConstrBuffer {
    uint data[];
}
constr_buffer;


uint constraint(uint other) {
    uint ret = (other << 1) | (other >> 1) | other;
    return ret % 0x10;
}

uint iter(uint idx) {
    return idx / (X * Y);
}

uint pos(uint idx) {
    return idx % (X * Y);
}

bool checkValid(uint idx1, uint idx2) {
    if (iter(idx1) == iter(idx2)) {
        return true;
    } else {
        return false;
    }
}


uint above(uint idx) {
    uint val = idx - X;
    return (checkValid(idx, val)) ? val : ERROR;
}

uint below(uint idx) {
    uint val = idx + X;
    return (checkValid(idx, val)) ? val : ERROR;
}

uint left(uint idx) {
    uint val = idx - 1;
    return (checkValid(idx, val)) ? val : ERROR;
}

uint right(uint idx) {
    uint val = idx + 1;
    return (checkValid(idx, val)) ? val : ERROR;
}


void main() {
    uint idx = gl_LocalInvocationIndex;

    uint arr[N_STATES] = { above(idx), below(idx), left(idx), right(idx) };
    uint state = my_data_buffer.data[idx];
    if (constr_buffer.data[idx] != 0) {
        my_data_buffer.data[idx] = constr_buffer.data[idx];
    } else {
        for (int i = 0; i < N_STATES; i++) {
            uint other_idx = arr[i];
            if (other_idx == ERROR) continue;
            if (constr_buffer.data[other_idx] != 0) {
                state &= constraint(constr_buffer.data[other_idx]);
            } else {
                state &= constraint(my_data_buffer.data[other_idx]);
            }
        }
        my_data_buffer.data[idx] = state;
    }
}
