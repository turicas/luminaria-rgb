package com.cursodeardruino.light;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;

import android.util.Log;

/**
 * Exemplo do HttpClient
 * 
 * Exemplos HttpClient: http://hc.apache.org/httpcomponents-client/examples.html
 * 
 * http://svn.apache.org/repos/asf/httpcomponents/httpclient/trunk/module-client
 * /src/examples/org/apache/http/examples/client/ClientConnectionRelease.java
 * 
 * @author ricardo
 * 
 */
public class HttpClientImpl extends Http {
	private final String CATEGORIA = "livro";

	@Override
	public final String downloadArquivo(String url) {
		try {
			HttpClient httpclient = new DefaultHttpClient();
			HttpGet httpget = new HttpGet(url);

			Log.i(CATEGORIA, "request " + httpget.getURI());
			HttpResponse response = httpclient.execute(httpget);

			Log.i(CATEGORIA, "----------------------------------------");
			Log.i(CATEGORIA, String.valueOf(response.getStatusLine()));
			Log.i(CATEGORIA, "----------------------------------------");

			HttpEntity entity = response.getEntity();

			if (entity != null) {
				Log.i(CATEGORIA, "Lendo resposta");
				InputStream in = entity.getContent();
				String texto = readString(in);
				return texto;
			}
		} catch (Exception e) {
			Log.e(CATEGORIA, e.getMessage(), e);
		}
		return null;
	}

	@Override
	public final byte[] downloadImagem(String url) {
		try {
			HttpClient httpclient = new DefaultHttpClient();
			HttpGet httpget = new HttpGet(url);

			Log.i(CATEGORIA, "request " + httpget.getURI());

			HttpResponse response = httpclient.execute(httpget);

			Log.i(CATEGORIA, "----------------------------------------");
			Log.i(CATEGORIA, String.valueOf(response.getStatusLine()));
			Log.i(CATEGORIA, "----------------------------------------");

			HttpEntity entity = response.getEntity();

			if (entity != null) {
				Log.i(CATEGORIA, "Lendo resposta...");
				InputStream in = entity.getContent();
				byte[] bytes = readBytes(in);
				Log.i(CATEGORIA, "Resposta: " + bytes);
				return bytes;
			}
		} catch (Exception e) {
			Log.e(CATEGORIA, e.getMessage(), e);
		}
		return null;
	}

	@Override
	public final String doPost(String url, Map map) {
		try {
			HttpClient httpclient = new DefaultHttpClient();
			HttpPost httpPost = new HttpPost(url);

			Log.i(CATEGORIA, "HttpClient.post " + httpPost.getURI());

			// cria os par�metros
			List<NameValuePair> params = getParams(map);
			// seta os parametros para enviar
			httpPost.setEntity(new UrlEncodedFormEntity(params, HTTP.UTF_8));

			Log.i(CATEGORIA, "HttpClient.params " + params);

			HttpResponse response = httpclient.execute(httpPost);

			Log.i(CATEGORIA, "----------------------------------------");
			Log.i(CATEGORIA, String.valueOf(response.getStatusLine()));
			Log.i(CATEGORIA, "----------------------------------------");

			HttpEntity entity = response.getEntity();

			if (entity != null) {
				InputStream in = entity.getContent();
				String texto = readString(in);
				Log.i(CATEGORIA, "Resposta: " + texto);
				return texto;
			}
		} catch (Exception e) {
			Log.e(CATEGORIA, e.getMessage(), e);
		}
		return null;
	}

	private byte[] readBytes(InputStream in) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		try {
			byte[] buf = new byte[1024];
			int len;
			while ((len = in.read(buf)) > 0) {
				bos.write(buf, 0, len);
			}

			byte[] bytes = bos.toByteArray();
			return bytes;
		} finally {
			bos.close();
		}
	}

	private String readString(InputStream in) throws IOException {
		byte[] bytes = readBytes(in);
		String texto = new String(bytes);
		return texto;
	}

	private List<NameValuePair> getParams(Map map) throws IOException {
		if (map == null || map.size() == 0) {
			return null;
		}

		List<NameValuePair> params = new ArrayList<NameValuePair>();

		Iterator e = (Iterator) map.keySet().iterator();
		while (e.hasNext()) {
			String name = (String) e.next();
			Object value = map.get(name);
			params.add(new BasicNameValuePair(name, String.valueOf(value)));
		}

		return params;
	}
}
