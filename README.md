# clock_vip

`clock_vip` is a UVM-based Verification IP (VIP) that provides a flexible and configurable way to generate various clock signals for digital design verification.

## Features

* **Configurable Clock Parameters**: Allows configuration of the following clock parameters:
    * Frequency
    * Duty cycle
    * Phase offset
    * Jitter
* **Clock Enable Control**: Enables dynamic enabling and disabling of clock signals.
* **Clock Monitoring**: Provides clock signal monitoring to verify frequency, duty cycle, and jitter against specifications.
* **Clock Fault Injection**: Supports clock fault injection to simulate various fault conditions, such as:
    * Clock stop
    * Clock glitch
    * Clock frequency offset
* **UVM Environment Integration**: Can be easily integrated into a Universal Verification Methodology (UVM) environment.

## Usage

1.  **Clone the Repository**: Clone the GitHub repository to your local machine.
2.  **Compile the Code**: Compile the SystemVerilog code using your SystemVerilog simulator.
3.  **Instantiate the VIP**: Instantiate the `clock_generator` VIP in your verification environment.
4.  **Configure the VIP**: Configure the clock parameters using the clkgen_config.sv
5.  **Monitor Clock Signals**: Use the VIP's monitoring features to verify the clock signals.

## Dependencies

* VCS simulator (The code is only verified on VCS simulator, the others simulator are still in progress)
* UVM verification environment

## License

MIT License

## Contributions

Feel free to submit pull requests to contribute code or fix bugs.

## Contact

For any questions or suggestions, please contact me through GitHub Issues.
