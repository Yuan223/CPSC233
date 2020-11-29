//Assignment4
//Yuan Liu 
//30087153


define(argc_r, w20)                                             //marco design
define(argv_r, x21)                                             //marco design
define(i_document, x22)                                         //marco design
define(j_index, x23)                                            //marco design
define(randomNum, x24)                                          //marco design
define(offset_r, x25)                                           //marco design
define(structureFrequencyIndex, x26)                            //marco design
define(structureFrequency, x27)                                 //marco design


        .text                                                   //Assembler Directives. Declare the memory region of the output information                                                     
fmtprintarg: .string "You have an array with size %d * %d\n"    //Print message repeat the arguments the user input         
fmtArgNumInvalid: .string "Please input valid numbers of arguments.(e.g. ./assign4 8 7)\n"        //Print message the user input invalid numbers of arguments
fmtArgValInvalid: .string "Please input valid value of arguments.(M, N should in range [4, 16])\n"        //Print message the user input invalid numbers of arguments
fmtArray: .string "\t%d "                                       //Print the 2D array 
fmtWrap: .string "\n"                                           //Wrap inn 2D array
fmtStructure: .string "Document: %d  \tIndex: %d  \tOccurence: %d  "//Print the information of document, index, and occurrence
fmtStructurefrequency: .string "\tFrequency:%d %\n"               //Print frequency
fmtTest: .string "This is for test %d \n"

fp .req x29                                                     //Initialize frame pointer
lr .req x30                                                     //Initialize link register

        .balign 4                                               //ARM-V8 4 bytes
        .global main                                            //Make main visible to the linker. The execution starts
main:                                                           // main label
        stp fp, lr, [sp, -16]!                                  //Stores the contents of the pair of registers to the stack. Saves the state of the registers. Allocates 16 bytes in stack memory.
        mov fp, sp                                              //Updates FP to the current SP

                                                                //Read argument
        mov argc_r, w0                                          //Read argc 
        mov argv_r, x1                                          //Read argv
        b checkArg                                              //Cheak sthe number of arguments

argNumInvalid:                                                  //argNumInvalid lable
        ldr x0, =fmtArgNumInvalid                               //Print "Please input valid numbers of arguments.(e.g. ./assign4 8 7)"
        bl printf                                               //
        b exit                                                  //then exit

argValInvalid:                                                  //argValInvalid lable
        ldr x0, =fmtArgValInvalid                               //Print "Please input valid value of arguments.(M, N should in range [4, 16])"
        bl printf                                               //
        b exit                                                  //then exit

checkArg:                                                       //checkArg lable
        cmp argc_r, 3                                           //if argc != 3
        b.lt argNumInvalid                                      //call argNumInvalid
        cmp argc_r, 3                                           //
        b.gt argNumInvalid                                      //

MNset:                                                          //MNset lable, set the arguments in argv to register. x19 = argv[0] and x20 = argv[1] 
        ldr x0, [argv_r, 8]                                     //Read argv[0]
        bl atoi                                                 //transfer arg[0] from char to int 
        mov x19, x0                                             //x19 = argv[0]
        ldr x0, [argv_r, 16]                                    //Read argv[1]
        bl atoi                                                 //transfer arg[1] from char to int 
        mov x20, x0                                             //x20 = argv[1]

        cmp x19, 4                                              //if (x19<4)
        b.lt argValInvalid                                      //call argValInvalid
        cmp x19, 16                                             //if (x19>16)
        b.gt argValInvalid                                      //call argValInvalid

        cmp x20, 4                                              //if (x20<4)
        b.lt argValInvalid                                      //call argValInvalid
        cmp x20, 16                                             //if (x20>16)
        b.gt argValInvalid                                      //call argValInvalid

        ldr x0, =fmtprintarg                                    //Print "You have an array with size M*N"
        mov x1, x19                                             //M = x19
        mov x2, x20                                             //N = x20
        bl printf                                               //

                                                                // Calculate alloc: M=x19, N=x20 //allocate = (2DArray + Structure) * 8 = (M * N + M * 4) * 8 = M * (N + 4) * 8
        add x21, x20, 4                                         // x21 = N + 4
        mul x21, x19, x21                                       // x21 = M * (N + 4)
        lsl x21, x21, 3                                         // x21 = M * (N + 4) * 8
        sub x21, xzr, x21                                       // x21 = - M * (N + 4) * 8
        and x21, x21, -16                                       // x21 = - (M * (N + 4) * 8) & -16
	add sp,	sp, x21                                         // move sp from high to with size (M * (N + 4) * 8) on stack

        mov x0, 0                                               //Initialize the register x0 to prepare the rand function
        bl time                                                 //Call time function
        bl srand                                                //Call srand function

        mov i_document, 0                                       //Initialize i_document
        mov j_index, 1                                          //Initialize j_index
     
        b testi_array                                           //Skip to testi_array

fillArray:                                                      //fillArray lable
        bl rand                                                 //Call rand function
        and randomNum, x0, 15                                   //random from 0 to 15
        add randomNum, randomNum, 1                             //random + 1. random from 1 to 16        
                                                                //the offset of the value in a[i][j] = (i * N + M) * 8
        mul offset_r, i_document, x20                           //offset = i * N
        add offset_r, offset_r, j_index                         //offset = i * N + j
        lsl offset_r, offset_r, 3                               //offset = (i * N + j) * 8
        sub offset_r, xzr, offset_r                             //-offset
        str randomNum, [fp, offset_r]                           //store random number to fp - offset = fp - (i * N + M) * 8

printArray:                                                     //printArray lable Read and print the random number
        adrp x0, fmtArray                                       //load fmtArray
        add x0, x0, :lo12:fmtArray                              //load fmtArray
        ldr x1, [fp, offset_r]                                  //x1 = fp - offset
        bl printf 

        add j_index, j_index, 1                                 // j_index ++

testj_array:                                                    //testj_array lable
        cmp j_index, x20                                        //if (j_index <= N){ 
        b.le fillArray                                          //      skip to fillArray}
                                                                //else{
        mov j_index, 1                                          //      j_index = 1
        add i_document, i_document, 1                           //      i_document ++}

        ldr x0, =fmtWrap                                        //Print wrap after print the value which index = N
        bl printf                                               //
        b testi_array                                           //Skip to testi_array

testi_array:                                                    //testi_array check i_document
        cmp i_document, x19                                     //if (i_document <= M){
        b.lt testj_array                                        //      skip to testj_array}

        mov i_document, 0                                       //Initializ i_document = 0
        mov j_index, 1                                          //Initializ j_index = 1
        mov structureFrequencyIndex, 0                          //Initializ structureFrequencyIndex = 0
        mov structureFrequency, 0                               //Initializ structureFrequency = 0
        mov x21, 0                                              //Initializ x21 = 0,  x21 is sum of occurrence in document i

        b testi_structure                                       //Skip to testi_structure
        
findGreaterFrequency:                                           //findGreaterFrequency lable
        mov structureFrequency, x24                             // structureFrequency = x24, since x24 is greater than structureFrequency
        mov structureFrequencyIndex, j_index                    // structureFrequencyIndex = j_index, j_index is the index of the value in x24

        b add_jcounter                                          //Skip to add_jcounter

findMostFrequency:                                              //findMostFrequency find the most frequency, the offset of the value in a[i][j] = (i * N + M) * 8
        mul offset_r, i_document, x20                           //offset = i * N
        add offset_r, offset_r, j_index                         //offset = i * N + M
        lsl offset_r, offset_r, 3                               //offset = (i * N + M) * 8
        sub offset_r, xzr, offset_r                             //-offset
        ldr x24, [fp, offset_r]                                 //read a[i][j] to x24 

        add x21, x21, x24                                       //x21 = x21 + x24, x21 is sum of the document i 

        cmp structureFrequency, x24                             //if(structureFrequency < occurrence in x24){
        b.lt findGreaterFrequency                               //      skip to findGreaterFrequency}

add_jcounter:                                                   //add_jcounter lable
        add j_index, j_index, 1                                 // j_index++
        b fillstructure                                         // Go to fillstructure 

fillstructure:                                                  //fillstructure lable
        cmp j_index, x20                                        //if(j_index <= N){
        b.le findMostFrequency                                  //      Skip to findMostFrequency}        

                                                                //offset of the base of document i = (M * N + i * 4) * 8
        mul offset_r, x19, x20                                  // offset = M * N
        mov x23, 4                                              //  x23 = 4
        mul x24, i_document, x23                                //  x24 = i_document * 4
        add offset_r, offset_r, x24                             // offset = M * N + i * 4   
        lsl offset_r, offset_r, 3                               // offset = (M * N + i * 4) * 8     
        sub offset_r, xzr, offset_r                             // offset = - offset                                      

        mov x23, 8                                              // x23 = 8
        sub x23, xzr, x23                                       // x23 = -8
        add offset_r, x23, offset_r                             //offset_r = offset - 8 
        str i_document, [fp, offset_r]                          //store i_document to fp-offset = fp - (M * N + i * 4) * 8 - 8
        
        add offset_r, x23, offset_r                             //offset_r = offset - 8 
        sub structureFrequencyIndex, structureFrequencyIndex, 1 //structureFrequencyIndex = structureFrequencyIndex - 1, since the initial j_index = 1
        str structureFrequencyIndex, [fp, offset_r]             //store structureFrequencyIndex to fp-offset = fp - (M * N + i * 4) * 8 - 16
        
        add offset_r, x23, offset_r                             //offset_r = offset - 8 
        str x21, [fp, offset_r]                                 //store x21(sum) to fp-offset = fp - (M * N + i * 4) * 8 - 24


printStructure:
        ldr x0, =fmtStructure                                   //Load fmtStructure
        mov x1, i_document                                      //Print "Document: %d  Index: %d  Occurence: %d  "
        mov x2, structureFrequencyIndex                         //
        mov x3, structureFrequency                              //
        bl printf

                                                                //Calculate the frequency, structureFrequency * 100 / sum of the word in document i
        mov x26, 100                                            //x26 = 100
        mul structureFrequency, structureFrequency, x26         //structureFrequency = structureFrequency * 100
        sdiv structureFrequency, structureFrequency, x21        //structureFrequency = structureFrequency * 100 / sum
        add offset_r, x23, offset_r                             //offset_r = offset - 8 
        str structureFrequency, [fp, offset_r]                  //store i_document to fp-offset = fp - (M * N + i * 4) * 8 - 32
        ldr x0, =fmtStructurefrequency                          //Print "Frequency:%d %\n"
        mov x1, structureFrequency                              //
        bl printf

        mov j_index, 1                                          //j_index = 1
        add i_document, i_document, 1                           //i_document ++
        mov structureFrequencyIndex, 0                          //structureFrequencyIndex = 0
        mov structureFrequency, 0                               //structureFrequency = 0
        mov x21, 0                                              //sum = x21 = 0

        b testi_structure                                       //Go to testi_structure

testi_structure:                                                //testi_structure lable
        cmp i_document, x19                                     //if(i_document < M){
        b.lt fillstructure                                      //      Skip to fillstructure}
                                                                //Calculate dealloc: M=x19, N=x20 //-deallocate = -(2DArray + Structure) * 8 = -(M * N + M * 4) * 8 = -M * (N + 4) * 8
        add x21, x20, 4                                         // x21 = N + 4
        mul x21, x19, x21                                       // x21 = M * (N + 4)
        lsl x21, x21, 3                                         // x21 = M * (N + 4) * 8
        sub x21, xzr, x21                                       // x21 = - M * (N + 4) * 8
        and x21, x21, -16                                       // x21 = - (M * (N + 4) * 8) & -16	
        sub x21, xzr, x21                                       // alloc = - dealloc
	add sp,	sp, x21                                         // move sp from high to with size -(M * (N + 4) * 8) on stack

exit:                                   //exit lable
        ldp fp, lr, [sp], 16            //restore the state of the FP and LR register
        ret                             //return control to calling code.       
