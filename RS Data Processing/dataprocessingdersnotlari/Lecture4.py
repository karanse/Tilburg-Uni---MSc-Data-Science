
# coding: utf-8

# Strings

# In[2]:


text='Hello!'
print(text)


# In[3]:


long_text=text+text


# In[4]:


long_text


# In[5]:


longest_text=text*4
print(longest_text)


# In[6]:


if text=='High!':
    print('do something')
else:
    print('do nothing')


# In[7]:


for letter in text:
    print(letter)


# In[9]:


text='Hello! Goodbye!' # Index starts from 0
print(text[1])


# In[12]:


def print_index(text):
    index=0
    for letter in text:
        print(index,":",text[index])
        index +=1


# In[13]:


print_index("ball")


# In[60]:


def is_vowel(letter):
    if letter in "aeuoi":
        return True
    return False


# In[62]:


is_vowel("b")


# In[28]:


def is_vowel(letter):
    return(letter in "aeiou")


# In[29]:


is_vowel("b")


# In[25]:


def is_vowel(letter):
    if letter in "aeuoi":   #ikinci else i yazmasak da olur
        return True
    else:
        return False


# In[36]:


def print_vowels(text):
    for letter in text:
        if letter in "aeiou":
            print(letter)


# In[37]:


print_vowels("this is my example")


# In[38]:


def count_vowels(text):
    count=0
    for letter in text:
        if is_vowel(letter):
            count+=1
    return count


# In[39]:


count_vowels("en")


# In[53]:


def find_space(text):
    index=0
    for letter in text:
        if letter==" ":
            return index
        index+=1
    return -1  
        
       
    


# In[56]:


find_space("a s ")


# In[57]:


def find_character(text,character):
    index=0
    for letter in text:
        if letter ==character:
            return index
        index+=1
    return -1
        


# In[59]:


find_character("apple","e")


# In[67]:


text="Hello! Goodbye!"  # finding the first one wanted in the paranthesis
text.find("!",6)     # 6dan sonrasinda parantez icindekini getir


# In[68]:


text.count("?")


# In[73]:


text="Hello! Goodbye!"
print(text)
print(text.lower())   # they dont change the text, only as a input parameter
print(text.upper())

print(text)
text=text.lower()
print(text)


# In[88]:


def clean_up(text):
    text2=text.strip(" \n\t\!\?")
    text3=text2.lower()
    return text3


def print_poem():
    input_file=open("pc_rose.txt", "r") 
    # r is read only
    for line in input_file:
        print(line.strip(" \n\,"))
    input_file.close()
    
print_poem()


# In[90]:


def clean_up(text):
    text2=text.strip(" \n\t\!\?")
    text3=text2.lower()
    return text3


def print_poem():
    input_file=open("pc_rose.txt", "r") 
    # r is read only
    for line in input_file:
        print(clean_up(line))
    input_file.close()
    
print_poem()


# In[102]:


def clean_up(text):
    return text.strip(" \n\t\!\?,.").lower()


def print_poem():
    input_file=open("pc_rose.txt", "r") 
    # r is read only
    for line in input_file:
        clean_line=clean_up(line)
        for word in clean_line.split():
            print(clean_up(word))
        
    input_file.close()
    
print_poem()


# In[107]:


def clean_up(text):
    return text.strip(" \n\t\!\?,.").lower()

def print_poem():
    input_file=open("pc_rose.txt", "r") 
    output_file=open("pc_rose_words.txt","w")
    # r is read only
    # w write, creates file
    for line in input_file:
        clean_line=clean_up(line)
        for word in clean_line.split():
            output_file.write(clean_up(word)+"\n")
        
    input_file.close()
    output_file.flush()
    output_file.close()
    
print_poem()


# In[ ]:


# strip sadece basta ve sondakiler icin.


# In[94]:


line="nor arm, nor face, nor any other part" # eger belirtmezsen sadece bosluklar ile boler: split with space
for word in line.split():
    print(word)  


# In[95]:


line="nor arm, nor face, nor any other part"
for word in line.split(","):
    print(word)


# In[96]:


line="day,12,44,6,34"
for i in line.split(","):
    print(i)


# In[101]:


line="nor arm, nor face, nor any other part" 
for word in line.split():
    print(clean_up(word))


# In[80]:


my_text="apple \norange"
print(my_text)


# In[82]:


my_text="\tapple \norange"
print(my_text)


# In[85]:


my_text="\tapple orange\t "
print(">"+my_text+"<")
print(">"+my_text.strip()+"<")

