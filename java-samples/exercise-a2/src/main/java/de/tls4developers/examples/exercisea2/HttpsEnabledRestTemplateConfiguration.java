package de.tls4developers.examples.exercisea2;

import org.apache.http.client.HttpClient;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.conn.ssl.TrustSelfSignedStrategy;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.ssl.SSLContextBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

import javax.net.ssl.SSLContext;
import java.io.FileInputStream;
import java.io.IOException;
import java.security.*;
import java.security.cert.CertificateException;

@Configuration
public class HttpsEnabledRestTemplateConfiguration {

    @Value("${http.client.ssl.trust-store}")
    private Resource keyStoreResource;

    @Value("${http.client.ssl.trust-store-password}")
    private String keyStorePassword;

    @Bean
    public RestTemplate restTemplate() throws IOException, CertificateException, NoSuchAlgorithmException,
            KeyStoreException, KeyManagementException, UnrecoverableKeyException {

        KeyStore keyStore = KeyStore.getInstance("pkcs12");
        keyStore.load(new FileInputStream(keyStoreResource.getFile()), keyStorePassword.toCharArray());

        SSLContext sslContext = new SSLContextBuilder()
                .loadTrustMaterial(
                        null,
                        new TrustSelfSignedStrategy())
                .loadKeyMaterial(keyStore, keyStorePassword.toCharArray())
                .build();
        SSLConnectionSocketFactory sslConnectionSocketFactory = new SSLConnectionSocketFactory(sslContext);
        HttpClient httpClient = HttpClients
                .custom()
                .setSSLSocketFactory(sslConnectionSocketFactory)
                .build();
        HttpComponentsClientHttpRequestFactory httpComponentsClientHttpRequestFactory =
                new HttpComponentsClientHttpRequestFactory(httpClient);
        return new RestTemplate(httpComponentsClientHttpRequestFactory);

    }

}
