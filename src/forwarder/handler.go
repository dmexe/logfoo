package main

import (
	"regexp"
	"strconv"
	"strings"
)

var (
	rbStackRe = regexp.MustCompile("^(.+):([0-9]+):(.*)")
)

type Handler struct {
	Entry *ExceptionEntry
}

func NewHandler() *Handler {
	return &Handler{
		Entry: NewExceptionEntry(),
	}
}

func (h *Handler) HandleLogfmt(bKey, bVal []byte) error {
	val := string(bVal)
	key := string(bKey)

	switch key {
	case "level":
		h.Entry.Level = val
	case "msg":
		h.Entry.Msg = val
	case "scope":
		h.Entry.Scope = val
	case "thread":
		h.Entry.Thread = val
	case "exception":
		h.Entry.Exception = val
	case "backtrace":
		lines := strings.Split(val, ",")
		stack := []StackFrame{}
		for _, line := range lines {
			res := rbStackRe.FindAllStringSubmatch(line, -1)
			if res != nil {
				line, _ := strconv.Atoi(res[0][2])
				stack = append(stack, StackFrame{
					File: res[0][1],
					Line: line,
					Func: res[0][3],
				})
			}
		}
		h.Entry.Backtrace = stack
	case "env":
		h.Entry.Env = val
	default:
		h.Entry.Payload[key] = val
	}

	return nil
}
