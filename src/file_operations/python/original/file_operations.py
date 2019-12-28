#!/usr/local/bin/python
import sys

def usage():
    print("Invalid arguments, use the program as decribed below. \n./{} <text_file_path> <keyword_to_search_for>".format(sys.argv[0]))

def main(command_arguments):
    # print usage if the script isn't called with correct parameters
    if len(command_arguments) != 3:
        usage()
        sys.exit(1)
    
    # get the text file path from command line parameter
    text_file_path = command_arguments[1]

    # try to open a file descriptor (https://docs.python.org/2.0/lib/os-fd-ops.html) for reading the file content
    # if file doesn't exist or fails with another reason, throw an exception
    try:
        file_descriptor = open(text_file_path, 'r')
    except OSError as err:
        print("Program cannot open the file, please check if file exists: {}, error: {}".format(text_file_path, err))
        # exit the execution with an error (1) https://shapeshed.com/unix-exit-codes/
        sys.exit(1)

    # get user input for the keyword to search for
    keyword_to_search = command_arguments[2]

    # read the first line of the file and assing it to a variable
    line_in_file = file_descriptor.readline()

    # lets start counting the number of occurences of the keyword
    num_of_occurences = 0

    # start the loop until the we reach the end of file
    while line_in_file:
        # if keyword is in the current line line increase the counter by 1
        #if keyword_to_search in line_in_file.split():
        #    num_of_occurences = num_of_occurences + 1
        for word_in_line in line_in_file.split():
            if keyword_to_search.lower() == word_in_line.lower():
                num_of_occurences = num_of_occurences + 1

        # set the line in file parameter to the next line
        line_in_file = file_descriptor.readline()

    # close the file descriptor (https://docs.python.org/2.0/lib/os-fd-ops.html)
    file_descriptor.close()

    # print the occurences and the keyword to the stdout
    print("Found \"{}\" occurences of the keyword \"{}\" in the file.".format(num_of_occurences, keyword_to_search))

# what is this? (https://stackoverflow.com/a/419185)
if __name__ == "__main__":
    # script gibi calistirildiysa
    main(sys.argv)
