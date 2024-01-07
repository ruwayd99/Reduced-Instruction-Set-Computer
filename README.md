# Reduced Instruction Set Computer (RISC) Project

This project involves the development of a Turing-complete Simple RISC Machine capable of executing 16-bit ARM instruction sets. Below, I'll discuss the challenges faced, key learnings, and future plans for the project. Afterwards I will give a detailed project overview. 

## Challenges Faced and Debugging Techniques

It goes without saying that a project like this involves countless hours of debugging and staring at the same piece of code trying to figure out what exactly went wrong. Here are some notable challenges I faced:

- **Error or Typo in Code:**
  Debugging required meticulous scrutiny due to errors or typos in the code.

- **Inefficient Code Implementation:**
  Initially, I started writing code without proper planning. I soon realized that some parts of my code were too lengthy, and the implementation was inefficient. I had also assigned too many states for my finite    state machine which made my code complicated

- **Inferred Latches:**
  Synthesis issues arose in Quartus due to inferred latches in the initial design.

## Approaches to Problem Solving and Key Takeaways

To overcome these challenges, these are some of the strategies I employed and my learnings

- **Modularization:**
  I made separate modules for each blob of hardware displayed in the diagrams below. This made it easier for debugging and implementing new features.

- **Design Planning:**
  I learned the importance of planning and designing the entire system before you start writing code. For example, I made diagrams to identify how each hardware should communicate with one another. I also create   flowcharts to figure out the states I need for my finite state machine in order to execute all the instructions.

## Debugging Strategies

Strategies to expedite debugging processes:

- **ModelSim WaveForm Generator:**
  After writing my simulation testbenches, I like to view the waveform generated in ModelSim to ensure correct behavior of the hardware. I also put random values for my input to check if I am getting the desired   result. 

- **Display Messages:**
  Sometimes my code doesn’t simply because of a typo, wrong bit assignments for my states in my finite state machine and many more. That’s why I like to employ display messages almost everywhere in my simulation    testbench which displays the output in every step. This helps me pinpoint where exactly the code went wrong. 

- **Error Bit:**
  I have an error bit that turns high whenever there is an error (e.g. I do not get the desired output). I also write code so that the simulation stops immediately when the error is high. This approach aids in       pinpointing the root cause of the issue promptly.

- **Edge Cases:**
  I like to identify the edge cases for my projects and write simulation testbenches that cover all these cases. These scenarios encompass the extreme or unexpected conditions that the system may encounter. I am     currently learning about formal verification methods and UVM so that I can employ it on my RISC machine. 

- **Web Search:**
  Last but not least, I can only find answers from StackOverflow and other platforms to troubleshoot the problem. It is especially useful when I receive error code from ModelSim and Quartus as I can learn more about it online

## Future Implementations

### Branching in C:
Currently in progress, I am expanding the functionality of the project by incorporating branches, utilizing both `for` and `while` loops in C. This enhancement aims to bring more versatility and control flow capabilities to the codebase.

### UVM and Constrained Random Verification:
As part of ongoing efforts, I am deepening my understanding of Universal Verification Methodology (UVM), with a specific emphasis on constrained random verification techniques. This knowledge acquisition will enable me to implement robust testing methodologies, leveraging randomized inputs to enhance test coverage for my RISC machine.

### 2-Way Superscalar Pipelined Processor:
Aiming for the next phase of project development, I have plans to implement a 2-way superscalar pipelined processor. This advanced processor architecture introduces parallelism, enhancing the execution efficiency of instructions. The implementation of this feature will contribute to the project's overall performance and computational capabilities.

## Project Overview

Here is a high-level illustration of the machine:

![image](https://github.com/ruwayd99/Reduced-Instruction-Set-Computer/assets/109923578/9cd16c2e-c2cc-4e0f-bfa5-0158108c0f0c)

![image](https://github.com/ruwayd99/Reduced-Instruction-Set-Computer/assets/109923578/c64f7b48-5c63-40f5-91aa-4e9add66397b)

The following diagram illustrates the ARM instruction encodings that the machine can run:

![image](https://github.com/ruwayd99/Reduced-Instruction-Set-Computer/assets/109923578/803b9642-d9c8-4102-ba90-291692835259)

![image](https://github.com/ruwayd99/Reduced-Instruction-Set-Computer/assets/109923578/0a883541-2534-45bb-bd96-481d11b98fd3)

## Brief description of each module

### Instruction decoder:
Responsible for decoding instructions and transmitting data to Datapath and FSM. It also receives instructions from the FSM based on what state it is in.

![image](https://github.com/ruwayd99/Reduced-Instruction-Set-Computer/assets/109923578/884a143f-621e-4ca1-bb96-b8f50967a500)

### Datapath: 

This module contains the register file for storing data to registers (8 in total), ALU for carrying out all the arithmetic operations, shifter to shift the bits, multiplexers to choose correct data_in and load enable registers to store the inputs and outputs. 

![image](https://github.com/ruwayd99/Reduced-Instruction-Set-Computer/assets/109923578/1b53538a-69f5-4874-8b70-58e89abf7324)

These are the encodings for the ALU operations:

![image](https://github.com/ruwayd99/Reduced-Instruction-Set-Computer/assets/109923578/f0e0696d-836f-4f04-a44b-1d8bb2ffd537)

These are the encodings for the shift operations:

![image](https://github.com/ruwayd99/Reduced-Instruction-Set-Computer/assets/109923578/b4a7285c-b382-4386-931b-e3ed2b8e7d1e)

The RTL diagram of the hardware after synthesis can be found here. 

## Testbench

The `RISC_top_tb` testbench executes the following ARM instructions (encoding is stored in data.txt)

![image](https://github.com/ruwayd99/Reduced-Instruction-Set-Computer/assets/109923578/4663524c-7e9f-428f-a667-16df6424b6c2)

I did a test run by putting the value 37 through the switches SW0 through SW7 (100101 in binary). After pressing the clock (KEY0) a couple of times, I get the desired output 74 (1001010 in binary) displayed on the red LEDs. 

This is a picture of the DE1-SoC board after I received the output. 

![20240107_140419](https://github.com/ruwayd99/Reduced-Instruction-Set-Computer/assets/109923578/e8568911-5c61-4411-88ef-2b02c6d65ca8)

Here is the video of me demonstrating it on the board: https://drive.google.com/file/d/1t0AIagljHpC8mslxzSB-MaZslU0uAJmQ/view?usp=sharing











