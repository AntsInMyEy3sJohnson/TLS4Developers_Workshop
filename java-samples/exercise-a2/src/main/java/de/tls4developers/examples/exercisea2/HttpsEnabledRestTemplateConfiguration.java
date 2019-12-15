package de.tls4developers.examples.exercisea2;

import org.apache.http.client.HttpClient;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.conn.ssl.TrustSelfSignedStrategy;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.ssl.SSLContextBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

import javax.net.ssl.SSLContext;
import java.io.IOException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.CertificateException;

@Configuration
public class HttpsEnabledRestTemplateConfiguration {

    @Bean
    public RestTemplate restTemplate() throws IOException, CertificateException, NoSuchAlgorithmException,
            KeyStoreException, KeyManagementException {

        SSLContext sslContext = new SSLContextBuilder()
                .loadTrustMaterial(null, new TrustSelfSignedStrategy())
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
