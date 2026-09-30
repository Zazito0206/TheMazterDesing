(function () {
  const settings = window.THE_MAZTER_SUPABASE || {};
  const ready = window.supabase &&
    /^https:\/\/.+\.supabase\.co$/.test(settings.url || "") &&
    settings.anonKey &&
    !settings.anonKey.includes("PASTE_");

  if (!ready) {
    window.portfolioDb = null;
    return;
  }

  const client = window.supabase.createClient(settings.url, settings.anonKey);
  const bucket = "portfolio-thumbnails";
  window.portfolioDb = {
    client,
    bucket,
    async listWorks() {
      const { data, error } = await client
        .from("portfolio_works")
        .select("id,title,category,image_path,created_at")
        .order("created_at", { ascending: false });
      if (error) throw error;
      return (data || []).map((work) => ({
        ...work,
        imageUrl: work.image_path
          ? client.storage.from(bucket).getPublicUrl(work.image_path).data.publicUrl
          : ""
      }));
    },
    async listCreators() {
      const { data, error } = await client
        .from("portfolio_creators")
        .select("id,name,url,created_at")
        .order("created_at", { ascending: false });
      if (error) throw error;
      return data || [];
    }
  };
})();
