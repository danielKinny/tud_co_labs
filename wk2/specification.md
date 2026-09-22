**a recursive routine is something that relies on calling itself, the routine logic in a simpler language would be as follows:**

```python
def factorial( int n ):
    if n == 1:
        return 1
    else:
        return n * factorial(n-1)
```

**in terms of assembly, considering registers would mean that the pseudocode would be as follows:**

1. call factorial with n inside **%RDI**

2. if **%RDI** == 1 jump to endfactorial which moves 1 into **%RAX**

3. attempting n*factorial(n-1):

- preserve the value of **%RDI** onto the stack
- decrement the value inside **%RDI** and call factorial with parameter **%RDI**, and returns the value inside **%RAX**
- since **%RAX** is also the return register for mulq, just multiply using **%RDI** as an operand

**==all the registers have been emboldened for the ease of our beloved TA's==**
