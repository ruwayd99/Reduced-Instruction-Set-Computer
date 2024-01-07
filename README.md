# Reduced Instruction Set Computer (RISC) Project

This project involves the development of a Turing-complete Simple RISC Machine capable of executing 16-bit ARM instruction sets. Below, I'll discuss the challenges faced, key learnings, and future plans for the project.

## Challenges Faced and Debugging Techniques

Developing a project of this nature involves extensive debugging and problem-solving. Here are some notable challenges encountered:

- **Error or Typo in Code:**
  Debugging required meticulous scrutiny due to errors or typos in the code.

- **Inefficient Code Implementation:**
  Initial code lacked proper planning, resulting in inefficiencies. Lengthy code sections and excessive finite state machine states complicated the implementation.

- **Inferred Latches:**
  Synthesis issues arose in Quartus due to inferred latches in the initial design.

## Approaches to Problem Solving and Key Takeaways

To overcome challenges and improve the project, several strategies were employed:

- **Modularization:**
  The hardware was divided into separate modules for clarity and ease of debugging.

- **Design Planning:**
  Importance of planning and designing the entire system before coding, utilizing diagrams and flowcharts for communication and finite state machine state identification.

## Debugging Strategies

Strategies to expedite debugging processes:

- **ModelSim WaveForm Generator:**
  Utilizing ModelSim's waveform generator to verify correct hardware behavior through simulation testbenches.

- **Display Messages:**
  Implementation of display messages throughout simulation testbenches to identify and rectify issues related to typos and state bit assignments.

- **Error Bit:**
  Introduction of an error bit that turns high in the presence of errors, facilitating prompt issue localization.

- **Edge Cases:**
  Identification and testing of edge cases through comprehensive simulation testbenches, addressing extreme or unexpected system conditions.

- **Web Search:**
  Leveraging online platforms, such as StackOverflow, to troubleshoot errors and gain insights into error codes from tools like ModelSim and Quartus.

## Future Implementations

### Branching in C:
Currently in progress, expanding the project's functionality by incorporating branches, utilizing both `for` and `while` loops in C.

### UVM and Constrained Random Verification:
Deepening understanding of Universal Verification Methodology (UVM), with a focus on constrained random verification. This knowledge will enhance testing methodologies, leveraging randomized inputs for improved coverage.

### 2-Way Superscalar Pipelined Processor:
Planning to implement a 2-way superscalar pipelined processor in the next phase of development. This advanced processor architecture introduces parallelism, enhancing instruction execution efficiency for improved overall performance.
