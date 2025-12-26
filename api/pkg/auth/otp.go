package auth

import (
	"crypto/rand"
	"fmt"
	"math/big"
)

// GenerateOTP generates a random 6-digit string
func GenerateOTP() string {
	n, _ := rand.Int(rand.Reader, big.NewInt(1000000))
	return fmt.Sprintf("%06d", n)
}
