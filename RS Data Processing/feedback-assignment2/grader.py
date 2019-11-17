import testing

SEP = "\n" + "*"*70 + "\n"

def report(passed_tests):
    # if import failed, print "assignment not passed"
    if passed_tests == 0:
        print("Assignment not passed.")
        print(SEP)
        return
    # otherwise report nr of testcases passed, and whether assignment was passed
    possible_points = sum([len(passed_tests[s]) for s in list(passed_tests)])
    score = sum([sum(passed_tests[s]) for s in list(passed_tests)])
    print(SEP)
    print("Your code passed {} of {} test cases.".format(score, possible_points))
    if score == possible_points:
        print("Assignment passed!")
    else:
        print("Assignment not passed.")
        print("Take a look at the feedback and try to improve your code.")
    print(SEP)

def grade(testcases):
    """
    IN
    f:      string containing name of the file to check
    Test:   name of Test from testing to perform
    minimum:nr of testcases the student needs to pass to pass the assignment

    OUT
    results: dict of function names and a list of integers indicating for each
    testcase of this function whether it was passed or not.

    Calls functions to test f on Test, provide feedback to the user & calculate
    score, and returns the nr of testcases the student passed.
    """
    failed_to_import = testing.import_test()

    if failed_to_import:
        return 0
    else:
        results = testing.check_all(testcases)
        return results
