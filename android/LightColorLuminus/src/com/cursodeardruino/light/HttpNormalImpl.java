package com.cursodeardruino.light;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Iterator;
import java.util.Map;

import android.util.Log;

/**
 * Classe que encapsula as requests HTTP utilizando a "HttpURLConnection"
 * 
 * @author ricardo
 * 
 */
public class HttpNormalImpl extends Http {
	private final String CATEGORIA = "livro";

	@Override
	public final String downloadArquivo(String url) {
		Log.i(CATEGORIA, "Http.downloadArquivo: " + url);
		try {
			// Cria a URL
			URL u = new URL(url);
			HttpURLConnection conn = (HttpURLConnection) u.openConnection();

			// Configura a requisi��o para get
			// connection.setRequestProperty("Request-Method","GET");
			conn.setRequestMethod("GET");
			conn.setDoInput(true);
			conn.setDoOutput(false);
			conn.connect();

			InputStream in = conn.getInputStream();

			// String arquivo = readBufferedString(sb, in);
			String arquivo = readString(in);

			conn.disconnect();

			return arquivo;
		} catch (MalformedURLException e) {
			Log.e(CATEGORIA, e.getMessage(), e);
		} catch (IOException e) {
			Log.e(CATEGORIA, e.getMessage(), e);
		}
		return null;
	}

	@Override
	public final byte[] downloadImagem(String url) {
		Log.i(CATEGORIA, "Http.downloadImagem: " + url);
		try {
			// Cria a URL
			URL u = new URL(url);

			HttpURLConnection connection = (HttpURLConnection) u.openConnection();
			// Configura a requisi��o para get
			connection.setRequestProperty("Request-Method", "GET");
			connection.setDoInput(true);
			connection.setDoOutput(false);

			connection.connect();

			InputStream in = connection.getInputStream();

			// String arquivo = readBufferedString(sb, in);
			byte[] bytes = readBytes(in);

			Log.i(CATEGORIA, "imagem retornada com: " + bytes.length + " bytes");

			connection.disconnect();

			return bytes;

		} catch (MalformedURLException e) {
			Log.e(CATEGORIA, e.getMessage(), e);
		} catch (IOException e) {
			Log.e(CATEGORIA, e.getMessage(), e);
		}
		return null;
	}

	@Override
	public String doPost(String url, Map params) {
		try {
			String queryString = getQueryString(params);
			String texto = doPost(url, queryString);
			return texto;
		} catch (IOException e) {
			Log.e(CATEGORIA, e.getMessage(), e);
		}
		return url;
	}

	// Faz um requsi��o POST na URL informada e retorna o texto
	// Os par�metros s�o enviados ao servidor
	private String doPost(String url, String params) throws IOException {
		Log.i(CATEGORIA, "Http.doPost: " + url + "?" + params);
		URL u = new URL(url);

		HttpURLConnection conn = (HttpURLConnection) u.openConnection();
		conn.setRequestMethod("POST");
		conn.setDoOutput(true);
		conn.setDoInput(true);

		conn.connect();

		OutputStream out = conn.getOutputStream();
		byte[] bytes = params.getBytes("UTF8");
		out.write(bytes);
		out.flush();
		out.close();

		InputStream in = conn.getInputStream();

		// le o texto
		String texto = readString(in);

		conn.disconnect();

		return texto;
	}

	// Transforma o HashMap em uma query string fazer o POST
	private String getQueryString(Map params) throws IOException {
		if (params == null || params.size() == 0) {
			return null;
		}
		String urlParams = null;
		Iterator e = (Iterator) params.keySet().iterator();
		while (e.hasNext()) {
			String chave = (String) e.next();
			Object objValor = params.get(chave);
			String valor = objValor.toString();
			urlParams = urlParams == null ? "" : urlParams + "&";
			urlParams += chave + "=" + valor;
		}
		return urlParams;
	}

	// Faz a leitura do array de bytes da InputStream retornada
	private byte[] readBytes(InputStream in) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		try {
			byte[] buffer = new byte[1024];
			int len;
			while ((len = in.read(buffer)) > 0) {
				bos.write(buffer, 0, len);
			}
			byte[] bytes = bos.toByteArray();
			return bytes;
		} finally {
			bos.close();
			in.close();
		}
	}

	// Faz a leitura do texto da InputStream retornada
	private String readString(InputStream in) throws IOException {
		byte[] bytes = readBytes(in);
		String texto = new String(bytes);
		Log.i(CATEGORIA, "Http.readString: " + texto);
		return texto;
	}
}