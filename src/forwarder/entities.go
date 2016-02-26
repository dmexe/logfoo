package main

type StackFrame struct {
	File string
	Line int
	Func string
}

type ExceptionEntry struct {
	Level     string
	Msg       string
	Scope     string
	Env       string
	Thread    string
	Exception string
	Backtrace []StackFrame
	Payload   map[string]string
}

func NewExceptionEntry() *ExceptionEntry {
	return &ExceptionEntry{
		Env:     "production",
		Payload: make(map[string]string),
	}
}
