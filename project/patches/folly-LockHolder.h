#ifndef FOLLY_LOCKHOLDER_H_
#define FOLLY_LOCKHOLDER_H_

#include <cassert>
#include <utility>
#include <folly/Portability.h>

namespace folly {

template<typename SharedLock>
class ReadHolderImpl;
template<typename SharedLock>
class UpgradedHolderImpl;
template<typename SharedLock>
class WriteHolderImpl;

template<typename SharedLock>
class ReadHolderImpl {
public:
  explicit ReadHolderImpl(SharedLock* lock) : lock_(lock) {
    if (lock_) {
      lock_->lock_shared();
    }
  }

  explicit ReadHolderImpl(SharedLock& lock) : lock_(&lock) {
    lock_->lock_shared();
  }

  ReadHolderImpl(ReadHolderImpl<SharedLock>&& other) noexcept : lock_(other.lock_) {
    other.lock_ = nullptr;
  }

  // down-grade
  explicit ReadHolderImpl(UpgradedHolderImpl<SharedLock>&& upgraded) : lock_(upgraded.lock_) {
    assert(upgraded.lock_ != nullptr);
    upgraded.lock_ = nullptr;
    if (lock_) {
      lock_->unlock_upgrade_and_lock_shared();
    }
  }

  explicit ReadHolderImpl(WriteHolderImpl<SharedLock>&& writer) : lock_(writer.lock_) {
    assert(writer.lock_ != nullptr);
    writer.lock_ = nullptr;
    if (lock_) {
      lock_->unlock_and_lock_shared();
    }
  }

  ReadHolderImpl& operator=(ReadHolderImpl<SharedLock>&& other) {
    std::swap(lock_, other.lock_);
    return *this;
  }

  ReadHolderImpl(const ReadHolderImpl<SharedLock>& other) = delete;
  ReadHolderImpl& operator=(const ReadHolderImpl<SharedLock>& other) = delete;

  ~ReadHolderImpl() {
    if (lock_) {
      lock_->unlock_shared();
      lock_ = nullptr;
    }
  }

  void unlock() {
      assert(lock_ != nullptr);
      lock_->unlock_shared();
      lock_ = nullptr;
  }

private:
  friend class UpgradedHolderImpl<SharedLock>;
  friend class WriteHolderImpl<SharedLock>;
  SharedLock* lock_;
};


template<typename SharedLock>
class UpgradeHolderImpl {
public:
  explicit UpgradeHolderImpl(SharedLock* lock) : lock_(lock) {
    if (lock_) {
      lock_->lock_upgrade();
    }
  }

  explicit UpgradeHolderImpl(SharedLock& lock) : lock_(&lock) {
    lock_->lock_upgrade();
  }

  explicit UpgradeHolderImpl(WriteHolderImpl<SharedLock>&& writer) {
    assert(writer.lock_ != nullptr);
    lock_ = writer.lock_;
    writer.lock_ = nullptr;
    if (lock_) {
      lock_->unlock_and_lock_upgrade();
    }
  }

  UpgradeHolderImpl(UpgradeHolderImpl<SharedLock>&& other) noexcept : lock_(other.lock_) {
    other.lock_ = nullptr;
  }

  UpgradeHolderImpl& operator=(UpgradeHolderImpl<SharedLock>&& other) {
    std::swap(lock_, other.lock_);
    return *this;
  }

  UpgradeHolderImpl(const UpgradeHolderImpl<SharedLock>& other) = delete;
  UpgradeHolderImpl& operator=(const UpgradeHolderImpl<SharedLock>& other) = delete;

  ~UpgradeHolderImpl() {
    if (lock_) {
      lock_->unlock_upgrade();
      lock_ = nullptr;
    }
  }

  void unlock() {
      assert(lock_ != nullptr);
      lock_->unlock_upgrade();
      lock_ = nullptr;
  }

private:
  friend class WriteHolderImpl<SharedLock>;
  friend class ReadHolderImpl<SharedLock>;
  SharedLock* lock_;
};


template<typename SharedLock>
class WriteHolderImpl {
public:
  explicit WriteHolderImpl(SharedLock* lock) : lock_(lock) {
    if (lock_) {
      lock_->lock();
    }
  }

  explicit WriteHolderImpl(SharedLock& lock) : lock_(&lock) { lock_->lock(); }

  // promoted from an upgrade lock holder
  explicit WriteHolderImpl(UpgradeHolderImpl<SharedLock>&& upgraded) {
    lock_ = upgraded.lock_;
    upgraded.lock_ = nullptr;
    if (lock_) {
      lock_->unlock_upgrade_and_lock();
    }
  }

  WriteHolderImpl(WriteHolderImpl<SharedLock>&& other) noexcept : lock_(other.lock_) {
    other.lock_ = nullptr;
  }

  WriteHolderImpl& operator=(WriteHolderImpl<SharedLock>&& other) {
    std::swap(lock_, other.lock_);
    return *this;
  }

  WriteHolderImpl(const WriteHolderImpl<SharedLock>& other) = delete;
  WriteHolderImpl& operator=(const WriteHolderImpl<SharedLock>& other) = delete;

  ~WriteHolderImpl() {
    if (lock_) {
      lock_->unlock();
    }
  }

  void unlock() {
      assert(lock_ != nullptr);
      lock_->unlock();
      lock_ = nullptr;
  }

private:
  friend class ReadHolderImpl<SharedLock>;
  friend class UpgradeHolderImpl<SharedLock>;
  SharedLock* lock_;
};

}  // namespace folly
#endif  // FOLLY_LOCKHOLDER_H_
