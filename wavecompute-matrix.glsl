#[compute]
#version 430
#define X 10
#define Y 10
#define ITERS 1
#define ERROR 50000u
#define N_STATES 2


shared uint state;


layout (local_size_x = X, local_size_y = Y, local_size_z = ITERS) in;
layout (set = 0, binding = 0, std430) restrict buffer StateBuffer {
    uint data[];
}
state_buffer;

layout (set = 0, binding = 1, std430) restrict buffer ConstrBuffer {
    uint data[];
}
constr_buffer;

layout (set = 0, binding = 2, std430) restrict buffer MatrixBuffer {
    uint data[];
}
matrix_buffer;

layout (set = 0, binding = 3, std430) restrict buffer ConfigBuffer {
    uint matrix_x;
    uint matrix_y;
    uint window_x;
    uint window_y;
}
config_buffer;

layout (set = 0, binding = 4, std430) restrict buffer DebugBuffer {
    uint data[];
}
debug_buffer;

void print_buffer(uint idx, uint val) {
    debug_buffer.data[idx] = val;
}

uint constraint(uint other) {
    uint ret = (other << 1) | (other >> 1) | other;
    return ret % 0x10;
}

uint iter(uint idx) {
    return idx / (X * Y);
}

uint XY2idx(uint x, uint y) {
    return y * X + x;
}

uint idx2X(uint idx) {
    return idx % X;
}

uint idx2Y(uint idx) {
    return idx / X;
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

uint possibleState(uint idx, uint start_x, uint start_y) {
    // start_x, start_y, upper_left coordinates in the matrix
    uint state = 1;
    state = (state << N_STATES) - 1;

    uint matrix_center_idx = (start_x + config_buffer.window_x / 2) * config_buffer.matrix_y + (start_y + config_buffer.window_y / 2);
    for (int y = 0; y < config_buffer.window_y; y++) {
        for (int x = 0; x < config_buffer.window_x; x++) {
            // skip center pixel
            if (x == config_buffer.window_x / 2 && y == config_buffer.window_y / 2) continue;

            uint matrix_idx = (start_x + x) * config_buffer.matrix_y + (start_y + y);

            uint global_start_x = idx2X(idx) - config_buffer.window_x / 2;
            uint global_start_y = idx2Y(idx) - config_buffer.window_y / 2;
            uint global_idx = XY2idx(global_start_x + x, global_start_y + y);



            if (!checkValid(idx, global_idx)) continue;
            if (idx2Y(global_idx) - idx2Y(idx) != (y - config_buffer.window_y / 2)) continue;
            //DEBUG
            if (idx == 22 && start_x == 0){
                print_buffer(y*3 + x,  (matrix_buffer.data[matrix_idx]));
            }
            if (idx == 22 && start_x == 0 && x==0 && y==0){
                print_buffer(13,  (matrix_buffer.data[matrix_idx]));
                print_buffer(14,  (state_buffer.data[global_idx]));
                print_buffer(15,  global_idx);
            }

            if ((state_buffer.data[global_idx] & matrix_buffer.data[matrix_idx]) == 0) {
                return 0;
            }

            state &= matrix_buffer.data[matrix_center_idx];
        }
    }
    //DEBUG
    if (idx == 22 && start_x == 1){
        print_buffer(12, state);
    }
    return state;
}

uint calculateState(uint idx) {
    // Iterate over a matrix in windows
    uint state = 0;
    for (int start_x = 0; start_x <= (config_buffer.matrix_x - config_buffer.window_x); start_x++) {
        for (int start_y = 0; start_y <= (config_buffer.matrix_y - config_buffer.window_y); start_y++) {
            state |= possibleState(idx, start_x, start_y);

        }
    }
    return state;
}

void main() {
    uint idx = gl_LocalInvocationIndex;
    print_buffer(0, XY2idx(1, 0));
    print_buffer(1, XY2idx(0, 1));

    uint state = state_buffer.data[idx];
    if (constr_buffer.data[idx] != 0) {
        state_buffer.data[idx] = constr_buffer.data[idx];
    } else {
        state = calculateState(idx);
        state_buffer.data[idx] = state;
    }
}

// TODO: Constrainty se po pridani musí pridat do state_bufferu
// TODO: presah mezi radky, spatna kontrola
