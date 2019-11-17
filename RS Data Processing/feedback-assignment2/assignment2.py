
# coding: utf-8

# **Sema Karan**  
# *ANR: 924823*

# Write a function multi3_odd that takes two numbers start and finish, and returns the number of numbers greater than or equal to start and less than finish which are odd and are multiplicates of 3:
# 
# def multi3_odd(start, finish):
# 
#         #fill in the body of the function and return the appropriate value.
# 
# For example, multi3_odd(2,13) returns 2 (because the only numbers between 2 and 13 that are odd and multiplicates of 3 are 3 and 9). 
# 
# You can assume that both start and finish are positive integers.

# In[33]:


def multi3_odd(start, finish):
    count =0
    for x in range(start,finish):
        #print(x)
        if x%2 ==1 and x%3 == 0:
            count +=1
    return(count)

