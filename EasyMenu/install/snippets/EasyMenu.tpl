<?php
/**
 * EasyMenu
 *
 * メニューを簡単に作るためのスニペット。
 *
 * @category snippet
 * @version  0.2.2
 * @license  GNU General Public License (GPL), https://www.gnu.org/licenses/gpl-3.0.html
 * @author   Yu.No (https://github.com/yuno25211415)
 * @lastupdate 2026/11/04
 * @internal @properties &
 * @internal @modx_category Custom
 * @internal @installset base, sample
 * @param string &parents 基準となる親リソースのID
 * @param string &documents 繰り返すリソースのID（カンマ区切りで指定）
 * @param string &ignoreDocuments 除外するリソースのID（カンマ区切りで指定）
 * @param integer &maxDepth 対象となるサブリソースの最大の深さ（-1で無制限）
 * @param integer &publicState 公開を対象とするか非公開を対象とするか（1 = 公開　0 = 非公開）
 * @param integer &ignoreHidden 「メニューに表示」項目で非表示としているリソースを除外するかどうか
 * @param integer &hideSubMenus 全サブメニューを非表示にするかどうか
 * @param integer &showSubMenuOnlyActive 現在位置（カレント）のみサブメニューを表示
 * @param string &where 追加条件（SQLのWHEREと同じ記述）
 * @param string &sortBy リストの並び順
 * @param string &orderBy 並び替えの基準となるリソース変数の方向（ASC = 昇順　DESC = 降順）
 * @param string &tvList 使用するテンプレート変数名（カンマ区切りで複数指定）
 * @param string &outerTpl メニューを囲うHTMLテンプレート
 * @param string &rowTpl メニューアイテムのHTMLテンプレート
 * @param string &innerTpl サブメニューを囲うHTMLテンプレート
 * @param string &innerRowTpl サブメニューアイテムのHTMLテンプレート
 * @param string &hereClass 現在位置（カレント）の場合のクラス名
 * @param string &openClass サブメニューが含まれる親メニューのクラス名（hideSubMenusが1の時は付かない）
 * @param string &parentClass サブメニューを持つ親メニューアイテムのクラス名（hideSubMenusに関係なく付く）
 * @param string &parentHereClass サブメニューの現在位置（カレント）が含まれる親メニューのクラス名
 * @param string &rowClass メニューアイテムのクラス名
 * @param string &noResults リソースが見つからなかった場合に出力するHTMLテンプレート
 * @example [[EasyMenu? &parents=`13`]]
 * @example [[EasyMenu? &documents=`13,117`]]
 */

// パラメーターの初期設定
if (!isset($ignoreDocuments)) $ignoreDocuments = '';
if (!isset($maxDepth)) $maxDepth = -1;
if (!isset($publicState)) $publicState = 1;
if (!isset($ignoreHidden)) $ignoreHidden = 1;
if (!isset($hideSubMenus)) $hideSubMenus = 0;
if (!isset($showSubMenuOnlyActive)) $showSubMenuOnlyActive = 0;
if (!isset($where)) $where = '';
if (!isset($sortBy)) $sortBy = 'menuindex';
if (!isset($orderBy)) $orderBy = 'ASC';
if (!isset($tvList)) $tvList = '';
if (!isset($outerTpl)) $outerTpl = '@CODE:<ul>[+wrap+]</ul>';
if (!isset($rowTpl)) $rowTpl = '@CODE:<li[+classes+]><a href="[+url+]">[+title+]</a>[+wrap+]</li>';
if (!isset($innerTpl)) $innerTpl = $outerTpl;
if (!isset($innerRowTpl)) $innerRowTpl = $rowTpl;
if (!isset($hereTpl)) $hereTpl = $rowTpl;
if (!isset($hereClass)) $hereClass = 'active';
if (!isset($openClass)) $openClass = 'open';
if (!isset($parentClass)) $parentClass = '';
if (!isset($parentHereClass)) $parentHereClass = '';
if (!isset($rowClass)) $rowClass = '';
if (!isset($noResults)) $noResults = '';
if (!isset($_level)) $_level = 1; // 階層（内部でスニペットを呼び出す場合に使用される）

if ($maxDepth == 0) return '';

$currentDocId  = $modx->documentIdentifier;
$snippetName   = $modx->getSnippetName();
$contTableName = evo()->db->getFullTableName('site_content');
$where         = str_replace('c.', $contTableName.'.', $where);

$ignoreDocIds = implode(',', array_filter(explode(',', $ignoreDocuments), fn ($x) => preg_match('/^[0-9]+$/', $x)));
if (!empty($ignoreDocIds)) $where .= (!empty($where) ? ' AND ' : '').$contTableName.'.id NOT IN ('.$ignoreDocIds.')';

if (preg_match('/^[0-9]+$/', $parents)) $parents = (int)$parents;

// evo()->addLog('['.$snippetName.'] parents: '.$parents, gettype($parents));
// evo()->addLog('['.$snippetName.'] documents: '.$documents, gettype($parents));

if (isset($parents) && (!empty($parents) || $parents === 0)) {
	// 直下全てのリソースの情報を取得
	$result = evo()->getDocumentChildren(
		$parents,
		$publicState,
		0,
		'*',
		$where,
		$sortBy,
		$orderBy
	);

	// evo()->addLog('['.$snippetName.'] 件数：'.count($result));
} else if (isset($documents) && !empty($documents)) {
	$docIds = explode(',', $documents);

	// 指定のリソースの情報を取得
	$result = evo()->getDocuments(
		$docIds,
		$publicState,
		0,
		'*',
		$where,
		$sortBy,
		$orderBy
	);

	// 順序をdocumentsの並びにあわせる
	if (count($docIds) > 1) {
		$result = array_reduce($docIds, function($r, $docId) use($result) {
			foreach ($result as $data) {
				if ($data['id'] == $docId) {
					$r[] = $data;
					return $r;
				}
			}
		}, []);
	}

	// evo()->addLog('['.$snippetName.'] 件数：'.count($result));
}

if (!isset($result)) return '';

$subHtml = '';

// メニューの構築
foreach ($result as $i => $data) {
	// メニューの非表示は対象外
	if ($ignoreHidden == 1 && $data['hidemenu'] == 1) continue;

	// サブリソースの数
	$childCount = count($modx->getDocumentChildren($data['id'], 1, 0, 'id'));

	// $modx->addLog('['.$snippetName.'] current id: '.$currentDocId.', this id: '.$data['id'], $data);

	$hasSubMenu       = $childCount > 0;
	$isCurrent        = $data['id'] === $currentDocId;
	$isSubMenuCurrent = $hasSubMenu && in_array($currentDocId, $modx->getChildIds($data['id']));
	$isOpen           = $hasSubMenu && ($hideSubMenus == 0 || ($hideSubMenus == 1 && $showSubMenuOnlyActive && ($isCurrent || $isSubMenuCurrent)));

	// クラス名の設定
	$classes = [$rowClass];

	// 親メニューのクラス名
	if ($hasSubMenu) $classes[] = $parentClass;

	// サブメニューを表示時の親メニューのクラス名
	if ($isOpen) $classes[] = $openClass;

	// サブメニューがカレントの親メニューのクラス名
	if ($isSubMenuCurrent) $classes[] = $parentHereClass;

	// 現在位置のクラス名
	if ($isCurrent) $classes[] = $hereClass;

	$classes = array_filter($classes);

	// エイリアス取得
	$alias = $modx->getAliasListing($data['id']);
	// evo()->addLog('['.$snippetName.'] エイリアス', $alias);

	// テンプレート変数を取得
	$tvs = !empty($tvList) ? array_reduce(
		evo()->getTemplateVars(explode(',', $tvList), 'name,value', $data['id']),
		function($r, $v) {
			$r['tv.'.$v['name']] = $v['value'];
			return $r;
		}, []
	) : [];

	// evo()->addLog('['.$snippetName.'] テンプレート変数', $tvs);

	$url = $alias['path'].(!empty($alias['path']) ? '/' : '').$alias['alias'].($alias['isfolder'] ? '/' : $modx->config['friendly_url_suffix']);
	$url = preg_replace('/\/index\.html$/', '/', $url);
	$url = preg_replace('/^index\.html$/', '', $url);

	// プレースホルダーの初期設定
	$placeholder = array_merge([
		'id'         => $data['id'],
		'number'     => $i + 1,
		'level'      => $_level,
		'title'      => $data['pagetitle'],
		'url'        => $url,
		'parent'     => $data['parent'],
		'classes'    => count($classes) > 0 ? ' class="'.implode(' ', $classes).'"' : '',
		'is_first'   => $i == 0,
		'is_last'    => $i + 1 == count($result),
		'is_current' => $isCurrent,
		'is_open'    => $isOpen,
		'sub_count'  => $childCount
	], $data, $tvs);

	if ($hasSubMenu) {
		// サブメニューの構築
		if ($hideSubMenus == 0 || ($hideSubMenus == 1 && $showSubMenuOnlyActive && ($isCurrent || $isSubMenuCurrent))) {
			$placeholder['wrap'] = $modx->runSnippet($modx->getSnippetName(), [
				'parents'               => $data['id'],
				'ignoreDocuments'       => $ignoreDocuments,
				'maxDepth'              => $maxDepth == -1 ? $maxDepth : $maxDepth - 1,
				'publicState'           => $publicState,
				'ignoreHidden'          => $ignoreHidden,
				'hideSubMenus'          => $hideSubMenus,
				'showSubMenuOnlyActive' => $showSubMenuOnlyActive,
				'where'                 => $where,
				'tvList'                => $tvList,
				'outerTpl'              => $innerTpl,
				'rowTpl'                => $innerRowTpl,
				'hereTpl'               => $hereTpl,
				'sortBy'                => $sortBy,
				'orderBy'               => $orderBy,
				'hereClass'             => $hereClass,
				'openClass'             => $openClass,
				'parentClass'           => $parentClass,
				'parentHereClass'       => $parentHereClass,
				'rowClass'              => $rowClass,
				'_level'                => $_level + 1
			]);
		}
	}

	// HTMLを生成
	$subHtml .= preg_match('/^@CODE:/', $rowTpl) ?
		$modx->parseText(preg_replace('/^@CODE:/', '', $rowTpl), $placeholder) :
		$modx->parseChunk($rowTpl, $placeholder, '[+', '+]');
}

// アウターHTMLを生成し出力
return empty($subHtml) ? $noResults : (preg_match('/^@CODE:/', $outerTpl) ?
	$modx->parseText(preg_replace('/^@CODE:/', '', $outerTpl), [
		'wrap' => $subHtml
	]) : $modx->parseChunk($outerTpl, [
		'wrap' => $subHtml
	], '[+', '+]'));
