# scheme
simplified scheme

1) What is this version of scheme?

   this version is used in linux x86_64 originating from chez scheme, and has least dependency on other libs for research purpose;
   and there are only two files to be bulit:
   
   ```
   a. out/scheme
   b. out/scheme.boot
   ```
   
2) How to build and install it?

   after git clone this project, you can simply make as follows:
   
   ```
   cd scheme
   make
   sudo make install
   ```
   
 3) How to use it?
   
   after installing scheme, you can do with it like any other interpreter:
   
   ```
   $ scheme
   > (+ 1342 253.35)
   1595.35
   > 
   ```
   or execute a script in batch mode:
   
   ```
   $ scheme --script ./myjob.ss
   ```
   
3) What to do next?
   - simplifying c and s code in src dir
   - build a static web server using this scheme
