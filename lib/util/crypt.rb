require 'openssl'
class Util::Crypt
  def self.encrypt(msg, key = 'phrase', salt = nil)
    enc  = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    enc.encrypt
    enc.pkcs5_keyivgen(key, salt)
    return enc.update(msg) + enc.final
  rescue
    return false
  end

  def self.decrypt(msg, key = 'phrase', salt = nil)
    dec = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    dec.decrypt
    dec.pkcs5_keyivgen(key, salt)
    dec.update(msg) + dec.final
  rescue
    return false
  end

  def self.encrypt_with_mime(msg, key = 'phrase')
    salt = OpenSSL::Random.random_bytes(8)
    msg = self.encrypt(msg, key, salt)
    "#{Base64.encode64(msg)} #{Base64.encode64(salt)}"
  rescue
    return false
  end

  def self.decrypt_with_mime(msg, key = 'phrase')
    msgs = msg.split(/ /)
    msg = Base64.decode64(msgs[0])
    salt = Base64.decode64(msgs[1])
    self.decrypt(msg, key, salt)
  rescue
    return false
  end
end