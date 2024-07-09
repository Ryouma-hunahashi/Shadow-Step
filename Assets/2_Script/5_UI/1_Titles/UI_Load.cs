using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System.Linq;
using System;

public class UI_Load : MonoBehaviour
{
    [SerializeField] private Canvas loadCanvas;
    [SerializeField] private AnimationCurve loadCurve;
    private float elapsedTime;
    [SerializeField] private float loadTime;

    [SerializeField] private Slider loadSlider;
    [SerializeField] private Animator loadAnim;
    [SerializeField] private Image fadeImage;

    private bool loadStartFlag = false;
    private bool loadFinFlag = false;
    private bool loadingScene = false;

    private static UI_Load instance;

    public bool GetLoadEnd() { return loadFinFlag; }
    public static UI_Load GetInstance() { return instance; }

    public Camera nextSceneCamera;
    Scene scene;
    private PlayerShadowMode shadowMode;

    // Start is called before the first frame update
    void Start()
    {
        loadCanvas = this.GetComponent<Canvas>();
        loadSlider = loadSlider.GetComponent<Slider>();
        loadAnim = loadAnim.GetComponent<Animator>();
        fadeImage = fadeImage.GetComponent<Image>();

        if (loadCanvas == null) { Debug.LogError("CanvasCmponentがない"); }
        if (loadCurve == null) { Debug.LogError("AnimationCurveがない"); }
        if (loadSlider == null) { Debug.LogError("Sliderがない"); }
        if (loadAnim == null) { Debug.LogError("Animatorがない"); }
        if (fadeImage == null) { Debug.LogError("Imageがない"); }

        loadCanvas.enabled = false;
        fadeImage.gameObject.SetActive(false);
        loadAnim.gameObject.SetActive(false);

        GameObject[] objs = GameObject.FindGameObjectsWithTag("Player");
        if (objs.Length > 0)
        {
            shadowMode = objs[objs.Length - 1].GetComponent<PlayerShadowMode>();

        }
    }

    // Update is called once per frame
    void Update()
    {
        if (loadStartFlag && !loadingScene)
        {
            //loadAnim.Play("LoadAnim");
            fadeImage.gameObject.SetActive(true);
            loadAnim.gameObject.SetActive(true);
            loadSlider.value = loadCurve.Evaluate(elapsedTime / loadTime);
            elapsedTime += Time.deltaTime;

            if (elapsedTime > loadTime)
            {
                elapsedTime = loadTime;

                if (loadSlider.value == 1)
                {
                    if (shadowMode != null)
                    {
                        shadowMode.isPause = false;
                    }
                    loadFinFlag = true;
                    nextSceneCamera.depth = 1;
                    scene = SceneManager.GetSceneAt(0);
                    SceneManager.UnloadSceneAsync(scene.name);
                }
            }
        }
    }

    public void StartLoad(string _sceneName)
    {
        // 非同期でシーン切り替えを行う
        SceneManager.LoadSceneAsync(_sceneName, LoadSceneMode.Additive).completed += OnSceneLoaded;

        loadCanvas.enabled = true;
        loadStartFlag = true;
        loadingScene = true;
    }

        private void OnSceneLoaded(AsyncOperation obj)
    {
        // 二つ目のシーンを取得する
        scene = SceneManager.GetSceneAt(1);
        // 二つ目のシーンカメラを取得してくる
        GameObject getNextCamera = scene.GetRootGameObjects().Where(obj => obj.CompareTag("MainCamera")).First();
        nextSceneCamera = getNextCamera.GetComponent<Camera>();
        // カメラの優先度を最低値にしておく
        nextSceneCamera.depth = -1;
        // すべて完了したらチェックを外す
        loadingScene = false;
        GameObject[] objs = GameObject.FindGameObjectsWithTag("Player");
        if (objs.Length > 0)
        {
            shadowMode = objs[objs.Length - 1].GetComponent<PlayerShadowMode>();
            shadowMode.isPause = true;
        }
    }

    // 現在シーンの個数をゲットする
    public static (Scene , Scene?) GetScenes()
    {
        Scene firstScene = SceneManager.GetActiveScene();
        Scene? secondScene = null;

        int count = SceneManager.sceneCount;

        if(count >1)
        {
            for (int i = 0; i < count; i++)
            {
                Scene scene = SceneManager.GetSceneAt(i);
                if(scene != firstScene)
                {
                    secondScene = scene;
                    break;
                }
            }
        }

        return (firstScene, secondScene);
    }
}
    
