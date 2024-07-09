using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using System.IO;

public class selectScene : EditorWindow
{
    private List<SceneAsset> scenes;
    private Vector2 scrollPos = Vector2.zero;

    [MenuItem("Custom tools/Scene Switcher")]
    static void Open()
    {
        GetWindow<selectScene>("SceneSwitcher");
    }

    private void OnEnable()
    {
        if (scenes == null)
        {
            scenes = new List<SceneAsset>();
            Load();
        }
    }

    private static string FilePath => $"{Application.persistentDataPath}/_sceneLauncher.sav";

    private void OnGUI()
    {
        EditorGUILayout.BeginHorizontal();
        var sceneAsset = EditorGUILayout.ObjectField(null, typeof(SceneAsset), false) as SceneAsset;
        if (sceneAsset != null && scenes.IndexOf(sceneAsset) < 0)
        {
            scenes.Add(sceneAsset);
            Save();
        }
        if (GUILayout.Button("Add current scene"))
        {
            var scene = EditorSceneManager.GetActiveScene();
            if (scene != null && scene.path != null &&
                scenes.Find(s => AssetDatabase.GetAssetPath(s) == scene.path) == null)
            {
                var asset = AssetDatabase.LoadAssetAtPath<SceneAsset>(scene.path);
                if (asset != null && scenes.IndexOf(asset) < 0)
                {
                    scenes.Add(asset);
                    Save();
                }
            }
        }
        EditorGUILayout.EndHorizontal();

        GuiLine();

        this.scrollPos = EditorGUILayout.BeginScrollView(this.scrollPos);
        for (var i = 0; i < scenes.Count; ++i)
        {
            var scene = scenes[i];
            EditorGUILayout.BeginHorizontal();
            var path = AssetDatabase.GetAssetPath(scene);
            if (GUILayout.Button("X", GUILayout.Width(20)))
            {
                scenes.Remove(scene);
                Save();
                --i;
            }
            else
            {
                if (GUILayout.Button("O", GUILayout.Width(20)))
                {
                    EditorGUIUtility.PingObject(scene);
                }
                if (GUILayout.Button(i > 0 ? "ª" : "@", GUILayout.Width(20)) && i > 0)
                {
                    scenes[i] = scenes[i - 1];
                    scenes[i - 1] = scene;
                    Save();
                }
                EditorGUI.BeginDisabledGroup(EditorApplication.isPlaying);
                if (GUILayout.Button(Path.GetFileNameWithoutExtension(path)))
                {
                    if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                    {
                        EditorSceneManager.OpenScene(path);
                    }
                }
                EditorGUI.EndDisabledGroup();
            }
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndScrollView();
    }

    private void Save()
    {
        var guids = new List<string>();
        foreach (var scene in scenes)
        {
            string guid;
            long localId;
            if (AssetDatabase.TryGetGUIDAndLocalFileIdentifier(scene, out guid, out localId))
            {
                guids.Add(guid);
            }
        }

        var content = string.Join("\n", guids.ToArray());
        File.WriteAllText(FilePath, content);
    }

    private void Load()
    {
        scenes.Clear();
        if (File.Exists(FilePath))
        {
            string content = File.ReadAllText(FilePath);
            foreach (var guid in content.Split(new char[] { '\n' }))
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                var scene = AssetDatabase.LoadAssetAtPath<SceneAsset>(path);
                if (scene != null)
                    scenes.Add(scene);
            }
        }
    }

    private void GuiLine(int height = 1)
    {
        GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(height) });
    }
}
