
# coding: utf-8

# **Sema Karan**  
# ANR: 924823
# 

# ### Task
# 
# Write a function days_in_seconds that takes a number days, and returns a string with the format `'X days = Y seconds'`, where X is equal to the value in the parameter days and Y is equal to the number of seconds in X days:
# 
# `def days_in_seconds(days):`
# 
#         #fill in the body of the function and return the appropriate value.
# 
# For example, days_in_seconds(3) returns '3 days = 259200 seconds'. 

# ### Solution

# In[14]:


def days_in_seconds(days):
    return str(days) +' days = '+ str(days*24*60*60) +' seconds'
days_in_seconds(3)


# In[15]:


print(days_in_seconds(3))

