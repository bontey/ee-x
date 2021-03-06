//
//  IInterstitialAd.hpp
//  ee_x
//
//  Created by Zinge on 10/6/17.
//
//

#ifndef EE_X_I_INTERSTITIAL_AD_HPP
#define EE_X_I_INTERSTITIAL_AD_HPP

#include <functional>
#include <string>

#include "ee/AdsFwd.hpp"

namespace ee {
namespace ads {
using InterstitialAdCallback = std::function<void()>;

class IInterstitialAd {
public:
    IInterstitialAd();
    virtual ~IInterstitialAd();

    virtual bool isLoaded() const = 0;

    virtual void load() = 0;

    virtual bool show() = 0;

    void setResultCallback(const InterstitialAdCallback& callback);

protected:
    friend MediationManager;

    void setDone();

private:
    InterstitialAdCallback callback_;
};
} // namespace ads
} // namespace ee

#endif /* EE_X_I_INTERSTITIAL_AD_HPP */
