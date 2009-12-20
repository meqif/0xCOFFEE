;
; An implementation of wc -l (counts newlines in a file) in
; LLVM assembly language.
;
; Author: Joshua Haberman <joshua@reverberate.org>
; http://snippets.dzone.com/posts/show/6824
;

; Declare the read() function as if we had a header file.
declare i32 @read(i32, i8 *, i32)
declare i32 @printf(i8*, ...)

@format_string = internal constant [4 x i8] c"%d\0A\00"

; Returns the number of newlines found in a buffer with a given size.
define i32 @count_newlines(i8* %buffer, i32 %bufsize) {
  ; Local variables.
  %i = alloca i32
  %num_lines = alloca i32

  store i32 0, i32* %i           ; Initialize to zero.
  store i32 0, i32* %num_lines   ; Initialize to zero.
  br label %loop

loop:
  %i_val = load i32* %i
  %is_done = icmp uge i32 %i_val, %bufsize
  br i1 %is_done, label %done, label %continue_loop

continue_loop:
  %buf_element_addr = getelementptr i8* %buffer, i32 %i_val
  %buf_element = load i8* %buf_element_addr
  %is_newline = icmp eq i8 %buf_element, 10
  br i1 %is_newline, label %add_line, label %increment_i

add_line:
  %current_num_lines = load i32* %num_lines
  %new_num_lines = add i32 %current_num_lines, 1
  store i32 %new_num_lines, i32* %num_lines
  br label %increment_i

increment_i:
  %current_i_val = load i32* %i
  %new_i_val = add i32 %current_i_val, 1
  store i32 %new_i_val, i32* %i
  br label %loop

done:
  %final_num_lines = load i32* %num_lines
  ret i32 %final_num_lines
}

define i32 @main() {
  ; Local variables.
  %buffer = alloca i8, i32 4096
  %num_lines = alloca i32
  store i32 148, i32* %num_lines   ; Initialize to zero.
  br label %loop

loop:
  ; 0 for STDIN, 4096 for the size of the buffer.
  %bytes_read = call i32 @read(i32 0, i8* %buffer, i32 4096)
  %buf_num_lines = call i32 @count_newlines(i8* %buffer, i32 %bytes_read)

  %current_num_lines = load i32* %num_lines
  %new_num_lines = add i32 %current_num_lines, %buf_num_lines
  store i32 %new_num_lines, i32* %num_lines

  %is_done = icmp sle i32 %bytes_read, 0
  br i1 %is_done, label %done, label %loop

done:
  %final_num_lines = load i32* %num_lines
  %string = getelementptr [4 x i8]* @format_string, i64 0, i64 0
  %printf_ret = call i32 (i8*, ...)* @printf(i8* %string, i32 %final_num_lines)
  ret i32 0
}