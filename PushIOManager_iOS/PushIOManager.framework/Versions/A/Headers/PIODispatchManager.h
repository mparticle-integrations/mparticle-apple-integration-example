//
//  PIODispatchManager.h
//  PushIOManager
//
//  Copyright © 2018 Oracle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Returns the new exception block which logs the exception if raised while executing the block.
 
 @return dispatch_block_t new block which logs the exception if raised.
 */
extern dispatch_block_t exceptionBlock(dispatch_block_t block);


/**
 Runs the given block asynchronosly on the given dispatch queue. It logs exception if raised while
 executing block.

 @param queue The target dispatch queue to which the block is submitted.
 @param block The block to submit to the target dispatch queue.
 */
extern void pio_dispatch_async(dispatch_queue_t queue, dispatch_block_t block);


/**
 Runs the given block synchronosly on the given dispatch queue. It logs exception if raised while
 executing block.
 
 @param queue The target dispatch queue to which the block is submitted.
 @param block The block to submit to the target dispatch queue.
 */
extern void pio_dispatch_sync(dispatch_queue_t queue, dispatch_block_t block);


/**
 Runs the given block asynchronosly on the `main` dispatch queue. It logs exception if raised while
 executing block.
 
 @param block The block to submit to the `main` dispatch queue.
 */
extern void pio_dispatch_main_queue(dispatch_block_t block);


/**
 Runs the given block asynchronosly on the given dispatch queue after seconds provided. It logs exception if raised while
 executing block.
 
 @param seconds This value tells how much to wait in seconds before executing block.
 @param queue The target dispatch queue to which the block is submitted.
 @param block The block to submit to the target dispatch queue.
 */
extern void pio_dispatch_after_on_queue(float seconds, dispatch_queue_t queue, dispatch_block_t block);

/**
 Runs the given block asynchronosly on the `main` dispatch queue after seconds provided. It logs exception if raised while
 executing block.
 
 @param seconds This value tells how much to wait in seconds before executing block.
 @param block The block to submit to the target dispatch queue.
 */
extern void pio_dispatch_after(float seconds, dispatch_block_t block);

