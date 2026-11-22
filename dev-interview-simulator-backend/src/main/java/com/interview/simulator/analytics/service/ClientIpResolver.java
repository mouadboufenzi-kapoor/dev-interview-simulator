package com.interview.simulator.analytics.service;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.regex.Pattern;

@Component
public class ClientIpResolver {

    private static final String CLIENT_IP_HEADER = "CF-Connecting-IP";

    private final boolean trustProxyHeaders;
    private final Pattern trustedProxies;

    public ClientIpResolver(
            @Value("${app.client-ip.trust-proxy-headers:false}") boolean trustProxyHeaders,
            @Value("${app.client-ip.trusted-proxies:}") String trustedProxies) {
        this.trustProxyHeaders = trustProxyHeaders;
        this.trustedProxies = trustedProxies.isBlank() ? null : Pattern.compile(trustedProxies);
    }

    public String resolve(HttpServletRequest request) {
        String peerAddress = request.getRemoteAddr();
        if (!trustProxyHeaders
                || trustedProxies == null
                || peerAddress == null
                || !trustedProxies.matcher(peerAddress).matches()) {
            return peerAddress;
        }
        String forwardedAddress = request.getHeader(CLIENT_IP_HEADER);
        if (forwardedAddress == null || forwardedAddress.isBlank()) {
            return peerAddress;
        }
        return forwardedAddress.trim();
    }
}
