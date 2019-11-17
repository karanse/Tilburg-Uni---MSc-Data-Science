import pickle

SEP = "\n" + "*"*70 + "\n"

def import_test():
    """
    prints some
    returns True if there is a problem importing the student's code
    """
    try:
        import assignment2
        return False
    except ImportError:
        print("""We could not find your solution. Check that it is called solution\
.py and stored in the same folder as the testing script.""")
        return True
    except SyntaxError:
        print("There is a Syntax Error in your solutions. Fix it and try again.")
        return True

def report_wrong_output(function, output, testcase):
    print(SEP)
    print("There is something wrong with your implementation of {}.".format(
        function))
    print("For this input:")
    print(testcase[0])
    print("your code outputs:")
    print(output)
    print("The desired output is:")
    print(testcase[1])

def report_wrong_type(function, output, testcase):
    print(SEP)
    print("There is something wrong with your implementation of {}.".format(
        function))
    print("With this input:")
    print(testcase[0])
    print("Your code outputs output of the type {}.".format(type(output).__name__))
    print("The desired output type is {}.".format(type(testcase[1]).__name__))

def report_name_error(function):
    print(SEP)
    print("Your solution does not contain a function {}.".format(function))
    print("Check that your functions are named correctly.")

def report_error(function, testcase):
    print(SEP)
    print("There is something wrong with your implementation of {}. ".format(function))
    print("It does not work with this input:")
    print(testcase[0])

def check_function(function, testcases, student_solution):
        """
        IN
        function:   function from students solutions
        inputs:     list of input, output tuple testcases
        OUT
        list of 0 (testcase failed) and 1 (testcase passed)
        """
        # TODO add checking of elements in tuple (for functions
        # that return more than one value)
        scores = []
        for testcase in testcases:
            passed = False
            try:
                output = student_solution[function](*testcase[0])
                # test if output if of correct type
                if type(output) == type(testcase[1]):
                    # test if it is correct
                    if output == testcase[1]:
                        passed = True
                    else:
                        report_wrong_output(function, output, testcase)
                else:
                    report_wrong_type(function, output, testcase)
            except KeyError:
                report_name_error(function)
            except Exception:
                report_error(function, testcase)
            finally:
                if passed:
                    scores.append(1)
                else:
                    scores.append(0)
        return scores

def check_all(testcases):
    """
    IN:
    testcases: string, name of a pickle file.
        dictionary:
            keys: function names to test
            values: lists:
                tuples:
                    input: WRAPPED IN A TUPLE (even if one arg; in that case the
                        input should look like this: (arg,)). If the input is
                        supposed to be 1 tuple (a, b), it should look like this:
                        ((a, b),) but if the input is 2 elements a & b, it
                        should look ike this: (a, b)
                    output: whatever you expect as output. if multiple, a tuple,
                    otherwise just one variable of desired type
    OUT:
    dictionary:
        keys: function names to test
        values: list of 1 if case was passed, 0 otherwise
    """
    results = {}
    student_solution = {}
    exec(open("assignment2.py").read(), student_solution)

    with open("testcases.p", "rb") as f:
        testcases = pickle.load(f)
    for function in testcases:
        tests_passed = check_function(function, testcases[function], student_solution)
        results[function] = tests_passed
    return results
