
# coding: utf-8

# In[ ]:


#Conditions and Iterations


# Assignment Answer

# In[2]:


def days_in_seconds(days):
    seconds=days*24*60*60
    message= str(days) + ' days = '+ str(seconds)+' seconds'
    return(message)


# In[3]:


days_in_seconds(1)


# In[1]:


def days_in_seconds(days):
    seconds=days*24*60*60
    if days==1:
        message= str(days) + ' day = '+ str(seconds)+' seconds'
    else:
        message= str(days) + ' days = '+ str(seconds)+' seconds'
        
    return message



# In[2]:


def days_in_seconds(days):
    seconds=days*24*60*60
    if days==1:
        message= str(days) + ' day = '+ str(seconds)+' seconds'
        return message
    else:
        message= str(days) + ' days = '+ str(seconds)+' seconds'
        return message


# In[1]:


def days_in_seconds(days):
    seconds=days*24*60*60
    if days==1:
        return str(days) + ' day = '+ str(seconds)+' seconds'

    return str(days) + ' days = '+ str(seconds)+' seconds'
       


# In[3]:


days_in_seconds(1)


# returnden sonra koda bisey almadigi icin, else e gerek yok

# In[ ]:


if (condition is true):
    do something
    else:
        do something else


# In[7]:


x=10 
if x==10:
    print('yay')


# In[8]:


x='apple'
if x=='apple':
    print('yay')


# In[11]:


x='apple'
y=10
if ((x=='apple') or (x=='banana')) and (y<100):
    print('yay')


# In[7]:


age=29
if age<18:
    print('you are a babe')
if (age>=18) and (age<=29):
    print('you are young')
if age>=29:
    print('you are very wise')


# In[5]:


age=29
if age<18:
    print('you are a babe')
if (age>=18) and (age<=29):
    print('you are young')
else:
    print('you are very wise')


# In[ ]:


# if ile yazarsak sonrakini de check ediyor ama else ile yazarsak etmiyor


# In[8]:


age=29
if age<18:
    print('you are a babe')
elif (age>=18) and (age<=29):
    print('you are young')
else:
    print('you are very wise')


# In[ ]:


#elif ile de yapilabilir ayni sey.Dogruysa gerisi skip et.


# In[13]:


age=21
if age<=18:
    print('you are a babe')
elif (age<=29):
    print('you are young')
elif (age<42):
    print('mature')
else:
    print('you are very wise')


# In[14]:


c=(age==21)


# In[15]:


c


# In[20]:


d=(5>4)


# In[21]:


d


# In[ ]:


#Bolean Values : True or False


# In[22]:


c=(age==21) or (age<30)


# In[23]:


c


# In[ ]:


# string icin de karakter aramasi yapabiliriz


# In[16]:


if 'c' in 'a new era':
    print('condition is true')
else:
    print('it is a false')


# In[17]:


def isVowel(char):
    if char in 'aeoui':     
        return True
    else:
        return False


# In[18]:


isVowel('a')


# In[19]:


isVowel('s')


# In[20]:


def isVowel(char):
        return char in 'aeoui'       
        


# In[21]:


isVowel('s')


# In[22]:


def isVowel(char):
    if char=="a":
        return True
    elif char=="e":
        return True
    elif char=="i":
        return True
    elif char=="o":
        return True
    elif char=="u":
        return True
    else:
        return False
    
    


# In[23]:


def isVowel(char):
    if char=="a" or char=="e" or char=="i" or char=="o" or char=="u" :
        return True
    else:
        return False


# In[ ]:


def calculate_tax(salary):
    tax_rate=0.22
    return salary*tax_rate    # under 1000 0.22, 2000 0.35, upper 


# In[35]:


def calculate_tax(salary):
    if salary< 1000:
        return (salary*0.22)
    elif salary >=1000 and salary< 2000:
        return(salary*0.35)
    elif salary >=2000:
        return(salary*0.40)


# In[ ]:


# for loop while loop


# In[36]:


print(1)
print(2)
print(3)


# In[ ]:


while (condition is true):
    do something
    
something else   # if statementlere benziyor: check the conditon, run the block over code until your condition is false


# In[24]:


counter=1
while (counter<=10):
    print(counter)
    counter=counter+1   #while kullanirken bi kosulda ilk kuralin bir yerde kirilmasi gerekir. Condition must become false at some time
    
print ("finished")


# In[25]:


def sum_n(n):
    counter=1
    total=0
    while (counter<=n):
        total=total+counter             
        counter+=1
    return total    #counter gibi baslangicta ustune loopla ekleyecegimiz variable gerekiyor.#No of rept is what you want and think your counter first


# In[26]:


sum_n(4)


# In[27]:


def sum_n(n):
    counter=1
    total=0
    while (counter<=n):
        total=total+n     
        counter+=1
    return total


# In[28]:


sum_n(4)


# In[ ]:


for x in collection:
    do something   # simpler but what a collection is you have to know


# In[31]:


for x in '12345':
    print('YAY')


# In[30]:


for x in '12345':
    print(x)
    print('YAY')


# In[32]:


for x in range(10):    # 10 e kadar
    print(x)


# In[33]:


for x in range(10,20):
    print(x)


# In[34]:


def multiplicates(number):
    for x in range (10):
        print(x*number)
    


# In[36]:


def multiplicates(number):
    for x in range (10):
        return(x*number)    
    #returndan sonra cikiyor looptan


# In[37]:


multiplicates(3)


# In[38]:


def multiplication_tables():
    for row in range (1,10):
        for column in range (0,10):
            print (row*column)
    
    #how many times you repeat in columns


# In[39]:


multiplication_tables()


# In[56]:


def multipliation_tables_1():
    for x in range(1,11):
        multiplicates(x)


# In[57]:


multipliation_tables_1()


# In[57]:


for fruit in ("apple","orange","pear"):
    print("I hate",fruit)

