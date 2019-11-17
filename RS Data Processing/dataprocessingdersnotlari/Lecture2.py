
# coding: utf-8

# In[ ]:


print(3425+44+22)
print(4)


# In[ ]:


my_sum=3+4+89


# In[ ]:


my_sum


# In[ ]:


print('this is my text')


# In[ ]:


salary=1200
tax_rate=0.22
tax=salary*tax_rate
net_salary=salary-tax
print('Gross salary',salary)
print('-------------')
print()
print('Tax:',tax)
print('-------------')
print()
print('Net Salary:',net_salary)
print('-------------')
print()


# In[1]:


def print_header(text):          #only takes one parameter and it is text


# In[14]:


def print_header(text):
    print(text)
    print('--------')
    print()


# In[3]:


salary_text='Gross salary: '+ str(1000)
print_header(salary_text)


# In[ ]:


net_salary


# In[ ]:


str(34) # string yapmak icin


# In[ ]:


int('56') # integer yapmak icin


# In[ ]:


x=int('56')
y=x*2
print(y)


# In[ ]:


str 


# In[ ]:


a=print('something') # print does not return back the values


# In[ ]:


a


# In[ ]:


salary=1200
tax_rate=0.22
tax=salary*tax_rate
net_salary=salary-tax

print_header('Gross salary'+str(salary))
print_header('Tax:'+ str(tax))
print_header('Net_salary:'+ str(net_salary))


# In[ ]:


def calculate_tax(salary):
    tax_rate=0.21
    tax=salary*tax_rate
    print (tax)


# In[ ]:


calculate_tax(1000)


# In[ ]:


def calculate_tax (salary):
    tax_rate=0.22
    tax=salary*tax_rate
    return tax  #return parantez almaz, sonucu saklamasi icin print yerine kullanilir: it returns the outcome


# In[4]:


def calculate_tax (salary):
    tax_rate=0.22
    tax=salary*tax_rate
    return tax


# In[5]:


my_tax=calculate_tax(2000)


# In[6]:


my_tax


# In[ ]:


def calculate_net(salary):
    tax_rate=0.22
    tax=salary*tax_rate
    net_salary=salary-tax
    return net_salary
    


# In[ ]:


my_net_salary=calculate_net(2000)


# In[ ]:


my_net_salary


# In[7]:


def calculate_tax (salary):
    tax_rate=0.22
    tax=salary*tax_rate
    return tax

def calculate_net(salary):
    tax=calculate_tax(salary)
    net_salary=salary-tax      #tekrar hesaplamak yerine functioni icinde kullanabiliriz. Ayni sekilde sonuclari dondurmek icin kulandigimiz return u da kullabiliriz
    return net_salary
    


# In[8]:


def compact_tax(salary):
    tax_rate= 0.22
    return tax_rate*salary

def compact_net(salary):
    return salary - compact_tax(salary)


# In[9]:


net_salary=compact_net(1000)


# In[10]:


net_salary


# In[11]:


net_salary=calculate_net(1000)


# In[12]:


net_salary


# In[13]:


def print_header(text): # ayni linede olmayinca function definition icinde yer almadigini dusunur
    print(text)
    print('--------')
    print()
print('finished')


# In[15]:


print_header('something')


# In[16]:


def calculate_tax (salary):
    tax_rate=0.22
    tax=salary*tax_rate
    print('I m here')
    return tax
    print('I am there')


# In[17]:


tax_rate=0.1
calculate_tax(1000)


# In[7]:


calculate_tax(1000)


# In[3]:


salary  # I dont have it outside the function, only available inside the function.Local to the function


# In[5]:


tax_rate


# In[ ]:


# return den baksa line varsa ise yaramaz, pyhon does not use anything after return function.


# In[13]:


def calculate_net(salary):
    tax_rate=0.22
    tax=salary*tax_rate
    net_salary=salary-tax
    return net_salary

def print_salary(salary):
    print('Salary is ' + str(calculate_net(salary)))
    print()


# In[14]:


print_salary(1000)


# In[15]:


def print_header(text):
    print(text)
    print('--------')
    print()

def print_salary(salary):
    tax_rate=0.22
    tax=salary*tax_rate
    net_salary=salary-tax
    
    print_header('tax:'+str(tax))
    print_header('net_salary:'+str(net_salary))
   



# In[16]:


print_salary(1000)

