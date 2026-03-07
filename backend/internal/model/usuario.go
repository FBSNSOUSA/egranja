package model

import (
	"time"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// Usuario representa um usuario do sistema (produtor ou tecnico).
type Usuario struct {
	ID             uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	Login          string    `gorm:"type:varchar(100);not null;uniqueIndex" json:"login" validate:"required,min=3,max=100"`
	PasswordDigest string    `gorm:"type:varchar(255);not null;column:password_digest" json:"-"`
	Nome           string    `gorm:"type:varchar(200)" json:"nome" validate:"max=200"`
	Tipo           string    `gorm:"type:varchar(20);not null;default:'produtor'" json:"tipo" validate:"required,oneof=produtor tecnico"`
	Ativo          bool      `gorm:"not null;default:true" json:"ativo"`
	CreatedAt      time.Time `gorm:"not null;default:now()" json:"created_at"`
	UpdatedAt      time.Time `gorm:"not null;default:now()" json:"updated_at"`

	// Relacionamentos
	Granjas []Granja `gorm:"foreignKey:UsuarioID" json:"granjas,omitempty"`
	Galpaos []Galpao `gorm:"foreignKey:UsuarioID" json:"galpaos,omitempty"`
	Lotes   []Lote   `gorm:"foreignKey:UsuarioID" json:"lotes,omitempty"`
}

func (Usuario) TableName() string {
	return "usuarios"
}

// BeforeCreate gera UUID se nao estiver definido.
func (u *Usuario) BeforeCreate(tx *gorm.DB) error {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	return nil
}

// SetPassword hasheia a senha com bcrypt.
func (u *Usuario) SetPassword(password string, cost int) error {
	hash, err := bcrypt.GenerateFromPassword([]byte(password), cost)
	if err != nil {
		return err
	}
	u.PasswordDigest = string(hash)
	return nil
}

// CheckPassword verifica a senha contra o hash armazenado.
func (u *Usuario) CheckPassword(password string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(u.PasswordDigest), []byte(password))
	return err == nil
}
