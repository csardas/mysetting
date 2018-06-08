#!/usr/bin/perl

# this script is to running some commands parallelly

#use warnings ;
use strict ;
use Getopt::Std ;
use Carp ;
use IO::Handle ;

use threads ;
use threads::shared ;
use Thread::Queue ;

my $time_start = time() ;

my $DEFAULT_Max_thread_num = 8 ;
my $DEFAULT_file_log = "mtRunning_$time_start.log" ;

my $opts = {} ;
getopts("c:l:p:hv", $opts) ;
die(usage()) if ($opts->{h}) ;
my $file_command_list = $opts->{c} or die ("\nError: argument -c is required\n\n" . usage() ) ;
my $file_log = $opts->{l} || $DEFAULT_file_log ;
my $MAX_thread_num = $opts->{p} || $DEFAULT_Max_thread_num ;
my $verbose = $opts->{v} ;
my $used_thread = 0 ;

my $count = {} ;


open (my $SRC_command,"$file_command_list") or die ("\nCan't open command file: $file_command_list\n$!\n\n") ;

# Thread 0: logging thread
open (my $TGT_appendlog , ">>$file_log") or die ("\nCan't open log file: $file_log\n$!\n\n");
autoflush $TGT_appendlog 1 ;
print $TGT_appendlog "\n\n" ;

my $logmsgQueue = Thread::Queue->new ;
my $log_thread = async {
    while (my $msg = $logmsgQueue->dequeue) {
	print $TGT_appendlog "$msg" ;
    }
} ;  
$logmsgQueue->enqueue(timelog("Start mtRunning")) ;
$used_thread ++ if ($verbose) ; # reserve one thread for logging


# Thread I: create result combine thread and Queue
my $combineQueue = Thread::Queue->new ;
my $combine_thread = async {
    $logmsgQueue->enqueue(timelog("Start result combine thread")) ;
    while (my $result = $combineQueue->dequeue) {
	$count->{runnung_job} ++ ;
	if ($verbose) {

	    my $iteration_verbose = 10 ;
	    if ($count->{cmd_num} > 100) {
		$iteration_verbose = 100 ;
	    }
	    unless ($count->{runnung_job} % 10) {
		$logmsgQueue->enqueue(timelog("$count->{runnung_job} jobs is executed")) ;
	    }
	}
	
	my $cmd = shift @$result ;
	my $output = join ("\n",map {chomp ; $_} @$result) ;

#	print "$output\n\n" ;
	
    }
} ;
$used_thread ++ ;

# Thread II: create works threads and jobQueue
my $jobQueue = Thread::Queue->new ;
my $worker_threads = [] ;
for (1 .. $MAX_thread_num - $used_thread) {
    push @$worker_threads , threads->create(\&processing_jobs) ;
    $logmsgQueue->enqueue(timelog("worker thread $_ created.")) ;
}

# Main I: read data and enqueue job
while (my $cmd = <$SRC_command>) {
    chomp $cmd ;
    $count->{cmd_num} ++ ;
    $logmsgQueue->enqueue(timelog("Get command $count->{cmd_num}: $cmd")) ;
    $jobQueue->enqueue($cmd) ;
}
$logmsgQueue->enqueue(timelog("Total enqueue $count->{cmd_num} commands.")) ;
close $SRC_command ;

# Thread II: close worker's queues
for (1 .. $MAX_thread_num - $used_thread) {
    $jobQueue->enqueue(undef) ;
}

# Thread II: join worker's threads
foreach (@$worker_threads) {
    $_->join ;
}

# Thread I: close combine Queue and thread
$logmsgQueue->enqueue(timelog("Total $count->{runnung_job} jobs executed.")) ;
$combineQueue->enqueue(undef) ;
$combine_thread->join ;

# Thread 0: logging thread finish and join
$logmsgQueue->enqueue(timelog("mtRunning done.")) ;
my $time_end = time() ;
my $opt_strings = join (" " ,map {("-$_") => $opts->{$_}} (sort keys %$opts) ) ;
$logmsgQueue->enqueue("\n$0 $opt_strings \nStart at\t" . localtime($time_start) . "\nEnd   at\t" . localtime($time_end) . "\n\n" ) ;
$logmsgQueue->enqueue(undef) ;
$log_thread->join ;
close $TGT_appendlog ;

#==============================
sub processing_jobs {
    while (my $cmd = $jobQueue->dequeue) {
	# running jobs and enqueue result to combine thread

	$combineQueue->enqueue([$cmd,`$cmd`]) ;
    }
}

sub timelog {
    my $msg = shift ;
    return localtime(time) . "\t$msg\n" ;
}

sub usage {

    return <<EOUsage
Usage :
    $0 -c FILE -l FILE\n
	-c  file with list of command	    (Required)
	-l  Log file			    (Optional)
	    (default = mtRunning_TIMESTAMP.log )    
	-p  Max runnung thread (default=8)  (Optional)
	-v  verbose mode		    (Optional) 
	-h  help, usage (this page)
EOUsage

} ;
