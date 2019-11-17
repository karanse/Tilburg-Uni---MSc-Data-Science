def summary(data):
    import numpy as np
    import numpy
    for col in data.dtype.names:
        print("column: {}".format(col))
        print("mean: {}".format(np.mean(data[col])))
        print("median: {}".format(np.median(data[col])))
        print("min: {}".format(np.min(data[col])))
        print("max: {}".format(np.max(data[col])))
        print("std: {}".format(np.std(data[col])))
        