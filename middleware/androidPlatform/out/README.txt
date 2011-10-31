*** native_pc platform (WUT) ***

Works as a bit more effective pc_proxy platform. It's built with a pmake script when choosing a node descriptor with "native_pc" entry in the <platform> tag.

The differences are as follows:
- after pmake finishes operation, the executable can be found at /build/null/main.exe; it is ready to be launched on a PC
- main.exe accepts "-n" parameter that assigns TOS_NODE_ID for the node
- by default, the DBG_ERROR, DBG_WARNING and DBG_APP debug channels are printed to stdout; to change that, you need to provide 'debug.cfg' file where channels names are listed, separated by semicolons (with a semicolon at the end)
-- special channel name "ALL_CHANNELS" can be used to turn on all debug channels (usually not recommended)

