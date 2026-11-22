package com.interview.simulator.analytics.service;

import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ClientIpResolverTest {

    private static final String TRUSTED_PROXIES =
            "10\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}|127\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}";

    private final ClientIpResolver disabled = new ClientIpResolver(false, TRUSTED_PROXIES);
    private final ClientIpResolver enabled = new ClientIpResolver(true, TRUSTED_PROXIES);

    @Test
    void disabledResolverKeepsTheSocketAddress() {
        assertEquals("127.0.0.1", disabled.resolve(request("127.0.0.1", "198.51.100.77")));
    }

    @Test
    void trustedProxyAddressIsReplacedByTheForwardedClient() {
        assertEquals("198.51.100.77", enabled.resolve(request("10.0.0.5", "198.51.100.77")));
        assertEquals("203.0.113.42", enabled.resolve(request("10.0.0.5", "203.0.113.42")));
    }

    @Test
    void forwardedHeaderFromAnUntrustedPeerIsIgnored() {
        MockHttpServletRequest request = request("203.0.113.9", "198.51.100.77");
        request.addHeader("X-Forwarded-For", "198.51.100.99");

        assertEquals("203.0.113.9", enabled.resolve(request));
    }

    @Test
    void xForwardedForIsNeverTrusted() {
        MockHttpServletRequest request = request("10.0.0.5", null);
        request.addHeader("X-Forwarded-For", "198.51.100.99");

        assertEquals("10.0.0.5", enabled.resolve(request));
    }

    @Test
    void missingProxyHeaderFallsBackToTheSocketAddress() {
        assertEquals("10.0.0.5", enabled.resolve(request("10.0.0.5", "  ")));
    }

    private static MockHttpServletRequest request(String peerAddress, String clientIp) {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setRemoteAddr(peerAddress);
        if (clientIp != null) {
            request.addHeader("CF-Connecting-IP", clientIp);
        }
        return request;
    }
}
