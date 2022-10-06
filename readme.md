# Ruby Cache Invalidation

This example shows a problem with prefork memory usage.

## Usage

Simply run `main.rb` to see the memory usage. The key point is that the child should share the parent memory as much as possible. However, when the child defines any module (`M = Module.new`) it appears the constant cache is invalidated.

### Bad Case

```
$ ./main.rb
...
** AFTER WARMUP **
1070574 ruby /home/samuel/Projects/ioquatix/ruby-memory-prefork/main.rb
   Processor Usage:     87.6% [████████████████████████████████████████████████████▋       ]
      Memory (PSS):  174.0MiB [████████████████████▍                                       ]
     Private (USS):  110.8MiB [█████████████                                               ]
1070628 ruby /home/samuel/Projects/ioquatix/ruby-memory-prefork/main.rb
   Processor Usage:      0.0% [                                                            ]
      Memory (PSS):  181.0MiB [█████████████████████▏                                      ]
     Private (USS):  118.2MiB [█████████████▉                                              ]
Summary
      Memory (PSS):  355.0MiB [█████████████████████████████████████████▋                  ]
...
```

Notice the total memory usage is around 350MiB, and the private memory usage (USS = unique set size) is around 100MiB. That's because `App.warmup` invalidates lots of shared pages.

### Good Case

```
$ M=1 ./main
...
** AFTER WARMUP **
1071410 ruby /home/samuel/Projects/ioquatix/ruby-memory-prefork/main.rb
   Processor Usage:     89.0% [█████████████████████████████████████████████████████▍      ]
      Memory (PSS):  125.7MiB [██████████████▊                                             ]
     Private (USS):   14.4MiB [█▊                                                          ]
1071413 ruby /home/samuel/Projects/ioquatix/ruby-memory-prefork/main.rb
   Processor Usage:      0.0% [                                                            ]
      Memory (PSS):  129.2MiB [███████████████▏                                            ]
     Private (USS):   18.2MiB [██▏                                                         ]
Summary
      Memory (PSS):  254.9MiB [█████████████████████████████▉                              ]
...
```

Notice the total memory usage is around 250MiB, and the private memory usage (USS) is around 18MiB. That's because most of the application memory is the same as the parent process.
