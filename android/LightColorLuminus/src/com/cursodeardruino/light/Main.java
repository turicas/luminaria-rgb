package com.cursodeardruino.light;

import yuku.ambilwarna.AmbilWarnaDialog;
import yuku.ambilwarna.AmbilWarnaDialog.OnAmbilWarnaListener;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

/** Código baseado no Código de Ricardo Lecheta com a 
 *  Utilizacao da Biblioteca de AmbilWarna library ("Pick a Color" in Indonesian)
 */
public class Main extends Activity {
	protected static final String CATEGORIA = "Luminaria_RGB";
	protected static String url = "";
	private MediaPlayer mMediaPlayer;
	protected int cor = 0xff000000;
	private ProgressDialog dialog;
	protected static Boolean Music = false;

	@Override
	protected void onCreate(Bundle icicle) {
		super.onCreate(icicle);

		setContentView(R.layout.main);

		Button b = (Button) findViewById(R.id.button);
		b.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				AmbilWarnaDialog colorDialog = new AmbilWarnaDialog(Main.this,
						cor, new OnAmbilWarnaListener() {
							@Override
							public void onOk(AmbilWarnaDialog colorDialog,
									int color) {

								if (Music){
									mMediaPlayer.stop();
								}
								cor = color;
								Context context = getApplicationContext();
								String rgb = java.lang.Integer
										.toHexString(color);

								String red = rgb.substring(2, 4);
								String green = rgb.substring(4, 6);
								String blue = rgb.substring(6, 8);

								CharSequence text = "Red: " + red + " Green: "
										+ green + " Blue: " + blue;

								int duration = Toast.LENGTH_LONG;

								Toast toast = Toast.makeText(context, text,
										duration);
								toast.show();

								dialog = ProgressDialog.show(Main.this, "",
										"Connecting...", false, true);

								try {
									// faz o download
									EditText e = (EditText) findViewById(R.id.edit_text);
									String endereco = e.getText().toString();
									url = "http://" + endereco + "/LED-" + red
											+ green + blue;
									final String arquivo = Http.getInstance(
											Http.NORMAL).downloadArquivo(url);

									Log.i(CATEGORIA, "Texto retornado: "
											+ arquivo);

									TextView t = (TextView) findViewById(R.id.status);
									t.setText(arquivo);

								} catch (Throwable e) {
									Log.i(CATEGORIA, e.getMessage(), e);
								} finally {
									dialog.dismiss();
								}
							}

							@Override
							public void onCancel(AmbilWarnaDialog colorDialog) {
								// cancel was selected by the user
								Context context = getApplicationContext();
								CharSequence text = "Cancelado";
								int duration = Toast.LENGTH_LONG;

								Toast toast = Toast.makeText(context, text,
										duration);
								toast.show();
							}

						});

				colorDialog.show();

			}
		});

		Button b2 = (Button) findViewById(R.id.button2);
		b2.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				Context context = getApplicationContext();

				if (Music){
					mMediaPlayer.stop();
				}
				
				int duration = Toast.LENGTH_LONG;

				Toast toast = Toast.makeText(context, "Modo Íntimo", duration);
				toast.show();

				try {
					EditText e = (EditText) findViewById(R.id.edit_text);
					String endereco = e.getText().toString();
					url = "http://" + endereco + "/modo-intimo";
					final String arquivo = Http.getInstance(Http.NORMAL)
							.downloadArquivo(url);

					Log.i(CATEGORIA, "Texto retornado: " + arquivo);
					
					
                    mMediaPlayer = MediaPlayer.create(context, R.raw.intimo);
                    mMediaPlayer.start();
                    Music = true;
					
					TextView t = (TextView) findViewById(R.id.status);
					t.setText(arquivo);

				} catch (Throwable e) {
					Log.i(CATEGORIA, e.getMessage(), e);
				}
			}
		});

		Button b3 = (Button) findViewById(R.id.button3);
		b3.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				Context context = getApplicationContext();

				if (Music){
					mMediaPlayer.stop();
				}
				
				int duration = Toast.LENGTH_LONG;

				Toast toast = Toast.makeText(context, "Aleatório", duration);
				toast.show();

				try {
					EditText e = (EditText) findViewById(R.id.edit_text);
					String endereco = e.getText().toString();
					url = "http://" + endereco + "/aleatorio";
					final String arquivo = Http.getInstance(Http.NORMAL)
							.downloadArquivo(url);

					Log.i(CATEGORIA, "Texto retornado: " + arquivo);
					
					TextView t = (TextView) findViewById(R.id.status);
					t.setText("Aleatório");

				} catch (Throwable e) {
					Log.i(CATEGORIA, e.getMessage(), e);
				}
			}
		});
		
		Button b4 = (Button) findViewById(R.id.button4);
		b4.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				Context context = getApplicationContext();

				if (Music){
					mMediaPlayer.stop();
				}
				
				int duration = Toast.LENGTH_LONG;

				Toast toast = Toast.makeText(context, "Dance Music", duration);
				toast.show();

				try {
					EditText e = (EditText) findViewById(R.id.edit_text);
					String endereco = e.getText().toString();
					url = "http://" + endereco + "/dance";
					final String arquivo = Http.getInstance(Http.NORMAL)
							.downloadArquivo(url);

					Log.i(CATEGORIA, "Texto retornado: " + arquivo);
					
					
                    mMediaPlayer = MediaPlayer.create(context, R.raw.dance);
                    mMediaPlayer.start();
                    Music = true;
					
					
					TextView t = (TextView) findViewById(R.id.status);
					t.setText(arquivo);

				} catch (Throwable e) {
					Log.i(CATEGORIA, e.getMessage(), e);
				}
			}
		});

		Button b5 = (Button) findViewById(R.id.button5);
		b5.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				Context context = getApplicationContext();

				if (Music){
					mMediaPlayer.stop();
				}
				
				int duration = Toast.LENGTH_LONG;

				Toast toast = Toast.makeText(context, "Desligar", duration);
				toast.show();

				try {
					EditText e = (EditText) findViewById(R.id.edit_text);
					String endereco = e.getText().toString();
					url = "http://" + endereco + "/LED-000000";
					final String arquivo = Http.getInstance(Http.NORMAL)
							.downloadArquivo(url);

					Log.i(CATEGORIA, "Texto retornado: " + arquivo);
					
					TextView t = (TextView) findViewById(R.id.status);
					t.setText(arquivo);

				} catch (Throwable e) {
					Log.i(CATEGORIA, e.getMessage(), e);
				}
			}
		});

		
	}

}