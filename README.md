# Christopher's compilation-tips

Here I collect and share some tips on how to compile numerical models on different machines.

List of architectures/machines and models from small to large:

## Macbook Pro M1Pro arm64 MacOSX15.1:

- WRF 4.6.1 (gfortran/gcc)
- WPS 4.6.0 (gfortran/gcc)
- cdo 2.4.4 (gcc)

## IMKIFU's owl HPC cluster:

- WRF 4.6.1 (Intel oneapi 2022 compilers)
- WPS, except ungrib 4.6.0 (Intel oneapi 2022 compilers)
- PALM-4U 24-04 (Intel oneapi 2022 compilers, gcc/gfortran, Intel 2021 compilers)

## KIT SCC's HoreKa HPC cluster (large machine):

- PALM-4U 23-10, 24-04 (Intel Compilers)

# Why all this testing with compilers, versions, machines, architectures?

## Numerical accuracy and precision

Interestingly, Renate Forkel and I found that on owl, it makes a difference if you compile the code with Intel or GNU compilers for PALM-4U. Within minutes after initialization for otherwise identical setups, we find slight differences in the windfield, which preticipate differences in the gasphase chemical species concentration fields. This is non-linear - "chaotic" - behaviour at work and why work on the microscale is interesting and challenging!

## Computational performance and optimization

For expensive code, like PALM-4U, it is useful to understand, under which conditions it performs optimally, or which setups and architectures work best together or should be avoided. For Intel machines we find largely linear scaling, while for some older AMD architectures like Rome and Milan, we found certain setup sweetspots, where for the same number of CPU seconds (i.e., kWh = $), we found substaintial differences in the number of gridpoints processed. More work (compute) per energy/money paid.

# License

All snippets and explaination here is licensed unter CC-BY-4. Please refer to the LICENSE.md file. As a scientist I live of acknowledgement, just like my colleagues.

# Acknowledgement

Figuring these environment settings and preparatory steps out took me a while, and I would like to express my thanks to the WRF team and community for their amazing documentation, as well as the amazing expert communities on stack exchange, reddit, Intel - and Apple developer forums. This little guide is a consolidation of small tips and nuggets I harvested from all those sources.
