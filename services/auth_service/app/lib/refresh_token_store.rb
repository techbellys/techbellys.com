class RefreshTokenStore
  PREFIX = "refresh_token"

  def self.key(user_id)
    "#{PREFIX}:#{user_id}"
  end

  def self.set(user_id, token, ttl = 7.days)
    $redis.set(key(user_id), token, ex: ttl)
  end

  def self.get(user_id)
    $redis.get(key(user_id))
  end

  def self.valid?(user_id, token)
    stored = get(user_id)
    stored.present? && stored == token
  end

  def self.invalidate(user_id)
    $redis.del(key(user_id))
  end
end
