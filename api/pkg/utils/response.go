package utils

import "strings"



type Response struct {
	Status  string      `json:"status"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
}

func Success(message string, data interface{}) Response {
	return Response{
		Status:  "success",
		Message: message,
		Data:    data,
	}
}

func Error(message string) Response {
	return Response{
		Status:  "error",
		Message: message,
		Data:    nil,
	}
}

// ParseError converts raw errors into user-friendly messages
func ParseError(err error) string {
	if err == nil {
		return "Unknown error"
	}
	msg := err.Error()
	// PostgreSQL Code 23505: unique_violation
	if strings.Contains(msg, "23505") {
		if strings.Contains(msg, "email") {
			return "Email is already registered"
		}
		return "Data already exists"
	}
	// PostgreSQL Code 23502: not_null_violation
	if strings.Contains(msg, "23502") || strings.Contains(msg, "violates not-null constraint") {
		// Try to extract column name. Format: ... column "title" ...
		start := strings.Index(msg, "column \"")
		if start != -1 {
			start += 8 // len("column \"")
			end := strings.Index(msg[start:], "\"")
			if end != -1 {
				column := msg[start : start+end]
				// Capitalize first letter
				if len(column) > 0 {
					column = strings.ToUpper(column[:1]) + column[1:]
				}
				return column + " is required"
			}
		}
		return "Required field is missing"
	}

	if strings.Contains(msg, "record not found") {
		return "Data not found"
	}
	return msg // Return original message if not caught (can be refined further)
}

func GetStatusCode(err error) int {
	if err == nil {
		return 200
	}
	msg := err.Error()
	if strings.Contains(msg, "email already exists") || strings.Contains(msg, "23505") || strings.Contains(msg, "user already verified") {
		return 409 // Conflict
	}
	if strings.Contains(msg, "record not found") {
		return 404 // Not Found
	}
	if strings.Contains(msg, "invalid") || strings.Contains(msg, "expired") || strings.Contains(msg, "23502") || strings.Contains(msg, "violates not-null constraint") {
		return 400 // Bad Request
	}
	return 500 // Internal Server Error
}
